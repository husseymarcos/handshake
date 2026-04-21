require "test_helper"

class ExperienceTest < ActiveSupport::TestCase
  test "experience is showcased with the newest first" do
    professionals(:alice).experiences.destroy_all
    older = professionals(:alice).experiences.create!(name: "Older Experience", year: 2020)
    newer = professionals(:alice).experiences.create!(name: "Newer Experience", year: 2024)
    assert_equal [ newer.id, older.id ], professionals(:alice).experiences.chronologically.pluck(:id)
  end

  test "undated experience appears after dated experience" do
    professionals(:alice).experiences.destroy_all
    dated = professionals(:alice).experiences.create!(name: "Dated", year: 2024)
    undated = professionals(:alice).experiences.create!(name: "Undated")
    assert_equal [ dated.id, undated.id ], professionals(:alice).experiences.chronologically.pluck(:id)
  end

  test "name is required" do
    experience = professionals(:alice).experiences.build(year: 2024)
    assert_not experience.valid?
    assert_includes experience.errors[:name], "can't be blank"
  end

  test "experiences with same year are ordered by created_at" do
    professionals(:alice).experiences.destroy_all
    first = professionals(:alice).experiences.create!(name: "First", year: 2024)
    second = professionals(:alice).experiences.create!(name: "Second", year: 2024)

    assert_equal [ second.id, first.id ], professionals(:alice).experiences.chronologically.pluck(:id)
  end

  test "year is optional" do
    experience = professionals(:alice).experiences.build(name: "No Year Project")
    assert experience.valid?
  end

  test "all fields except name and professional are optional" do
    experience = professionals(:alice).experiences.build(
      name: "Minimal Project"
    )
    assert experience.valid?
    assert experience.save
    assert_nil experience.year
    assert_nil experience.title
    assert_nil experience.description
    assert_nil experience.stack
    assert_nil experience.github_url
  end

  test "belongs to professional" do
    experience = experiences(:handshake)
    assert_equal professionals(:alice), experience.professional
  end

  test "destroying professional destroys dependent experiences" do
    experience = professionals(:alice).experiences.first

    professionals(:alice).destroy

    assert_not Experience.exists?(experience.id)
  end

  test "chronologically scope handles nil years correctly" do
    professionals(:alice).experiences.destroy_all
    nil_year1 = professionals(:alice).experiences.create!(name: "Nil One")
    sleep 0.01
    nil_year2 = professionals(:alice).experiences.create!(name: "Nil Two")

    result = professionals(:alice).experiences.chronologically.pluck(:id)
    assert_equal [ nil_year2.id, nil_year1.id ], result
  end

  test "year can be any integer" do
    [ 1990, 2000, 2024, 2050 ].each do |year|
      experience = professionals(:alice).experiences.build(name: "Year #{year}", year: year)
      assert experience.valid?, "Expected year #{year} to be valid"
    end
  end

  test "github_url can be nil" do
    experience = professionals(:alice).experiences.build(name: "No URL", github_url: nil)
    assert experience.valid?
  end

  test "stack can be nil" do
    experience = professionals(:alice).experiences.build(name: "No Stack", stack: nil)
    assert experience.valid?
  end
end
