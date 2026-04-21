require "test_helper"

class ResumeAdapterTest < ActiveSupport::TestCase
  test "raises MissingApiKeyError when API key is not set" do
    with_env("GEMINI_API_KEY" => nil) do
      adapter = ResumeAdapter.new(professionals(:alice))

      assert_raises(ResumeAdapter::MissingApiKeyError) do
        adapter.adapt(organization_name: "Test", posting: "Job")
      end
    end
  end

  test "raises MissingApiKeyError when API key is blank" do
    with_env("GEMINI_API_KEY" => "   ") do
      adapter = ResumeAdapter.new(professionals(:alice))

      assert_raises(ResumeAdapter::MissingApiKeyError) do
        adapter.adapt(organization_name: "Test", posting: "Job")
      end
    end
  end

  test "cache_key includes professional id" do
    adapter = ResumeAdapter.new(professionals(:alice))
    key1 = adapter.cache_key_for("Org", "Posting")

    adapter2 = ResumeAdapter.new(professionals(:bob))
    key2 = adapter2.cache_key_for("Org", "Posting")

    assert_not_equal key1, key2
  end

  test "cache_key includes organization name" do
    adapter = ResumeAdapter.new(professionals(:alice))
    key1 = adapter.cache_key_for("Org1", "Posting")
    key2 = adapter.cache_key_for("Org2", "Posting")

    assert_not_equal key1, key2
  end

  test "cache_key includes posting content" do
    adapter = ResumeAdapter.new(professionals(:alice))
    key1 = adapter.cache_key_for("Org", "Posting1")
    key2 = adapter.cache_key_for("Org", "Posting2")

    assert_not_equal key1, key2
  end

  test "cache_key is deterministic" do
    adapter = ResumeAdapter.new(professionals(:alice))
    key1 = adapter.cache_key_for("Org", "Posting")
    key2 = adapter.cache_key_for("Org", "Posting")

    assert_equal key1, key2
  end

  test "cache_key uses SHA256 hash" do
    adapter = ResumeAdapter.new(professionals(:alice))
    key = adapter.cache_key_for("Org", "Posting")

    assert_match(/handshake\/resume_typst\/v2\/[a-f0-9]{64}/, key)
  end

  test "system instruction mentions Typst CLI" do
    adapter = ResumeAdapter.new(professionals(:alice))
    instruction = adapter.send(:system_instruction)

    assert_match(/Typst CLI/, instruction)
    assert_match(/single.*page/i, instruction)
  end

  test "user prompt includes blueprint body" do
    adapter = ResumeAdapter.new(professionals(:alice))
    prompt = adapter.send(:user_prompt, "TestOrg", "Job posting", nil)

    assert_includes prompt, Blueprint.body
  end

  test "user prompt includes capabilities" do
    adapter = ResumeAdapter.new(professionals(:alice))
    prompt = adapter.send(:user_prompt, "TestOrg", "Job posting", nil)

    professionals(:alice).capabilities.each do |cap|
      assert_includes prompt, cap.name
    end
  end

  test "user prompt handles professional with no capabilities" do
    professionals(:carol).capabilities.destroy_all
    adapter = ResumeAdapter.new(professionals(:carol))
    prompt = adapter.send(:user_prompt, "TestOrg", "Job posting", nil)

    assert_match(/none yet/, prompt)
  end

  test "user prompt includes experiences" do
    adapter = ResumeAdapter.new(professionals(:alice))
    prompt = adapter.send(:user_prompt, "TestOrg", "Job posting", nil)

    professionals(:alice).experiences.each do |exp|
      assert_includes prompt, exp.name
    end
  end

  test "user prompt handles professional with no experiences" do
    professionals(:carol).experiences.destroy_all
    adapter = ResumeAdapter.new(professionals(:carol))
    prompt = adapter.send(:user_prompt, "TestOrg", "Job posting", nil)

    assert_match(/none listed/, prompt)
  end

  test "user prompt includes organization name" do
    adapter = ResumeAdapter.new(professionals(:alice))
    prompt = adapter.send(:user_prompt, "Acme Corp", "Job posting", nil)

    assert_includes prompt, "Acme Corp"
  end

  test "user prompt includes posting" do
    adapter = ResumeAdapter.new(professionals(:alice))
    prompt = adapter.send(:user_prompt, "TestOrg", "Looking for a Ruby dev", nil)

    assert_includes prompt, "Looking for a Ruby dev"
  end

  test "user prompt includes refinement when provided" do
    adapter = ResumeAdapter.new(professionals(:alice))
    refinement = "Make it shorter"
    prompt = adapter.send(:user_prompt, "TestOrg", "Job posting", refinement)

    assert_includes prompt, "Make it shorter"
    assert_match(/Layout constraint/, prompt)
  end

  test "user prompt excludes refinement when nil" do
    adapter = ResumeAdapter.new(professionals(:alice))
    prompt = adapter.send(:user_prompt, "TestOrg", "Job posting", nil)

    assert_not_includes prompt, "Layout constraint"
  end

  test "experience_bullet formats experience with all fields" do
    experience = professionals(:alice).experiences.first
    adapter = ResumeAdapter.new(professionals(:alice))
    bullet = adapter.send(:experience_bullet, experience)

    assert_includes bullet, experience.name
    assert_includes bullet, experience.year.to_s
    assert_includes bullet, experience.title
    assert_includes bullet, experience.description
    assert_includes bullet, experience.stack
    assert_includes bullet, experience.github_url
  end

  test "experience_bullet handles experience without year" do
    experience = experiences(:undated_experience)
    adapter = ResumeAdapter.new(professionals(:alice))
    bullet = adapter.send(:experience_bullet, experience)

    assert_includes bullet, experience.name
    assert_not_includes bullet, "(#{experience.year})"
  end

  test "experience_bullet handles experience without title" do
    experience = professionals(:alice).experiences.create!(name: "No Title", year: 2024)
    adapter = ResumeAdapter.new(professionals(:alice))
    bullet = adapter.send(:experience_bullet, experience)

    assert_not_includes bullet, "— "
  end

  test "experience_bullet handles experience without description" do
    experience = professionals(:alice).experiences.create!(name: "No Desc", year: 2024, title: "Dev")
    adapter = ResumeAdapter.new(professionals(:alice))
    bullet = adapter.send(:experience_bullet, experience)

    assert_includes bullet, experience.name
    # Should only have 2 parts: name with year, and title (no description)
    dash_count = bullet.count("—")
    assert_equal 1, dash_count
  end

  test "experience_bullet handles experience without stack" do
    experience = professionals(:alice).experiences.create!(
      name: "No Stack",
      year: 2024,
      title: "Dev",
      description: "Description"
    )
    adapter = ResumeAdapter.new(professionals(:alice))
    bullet = adapter.send(:experience_bullet, experience)

    assert_not_includes bullet, "["
  end

  test "experience_bullet handles experience without github_url" do
    experience = professionals(:alice).experiences.create!(
      name: "No URL",
      year: 2024,
      title: "Dev",
      description: "Description",
      stack: "Ruby"
    )
    adapter = ResumeAdapter.new(professionals(:alice))
    bullet = adapter.send(:experience_bullet, experience)

    assert_not_includes bullet, "http"
  end

  private

    def with_env(vars)
      original = {}
      vars.each do |key, value|
        original[key] = ENV[key]
        ENV[key] = value
      end
      yield
    ensure
      original.each do |key, value|
        ENV[key] = value
      end
    end
end
