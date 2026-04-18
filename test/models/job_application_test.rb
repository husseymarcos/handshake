require "test_helper"

class JobApplicationTest < ActiveSupport::TestCase
  test "truncates job descriptions that exceed the token budget" do
    user = users(:alice)
    body = "x" * (Handshake::JOB_DESCRIPTION_MAX_CHARS + 500)
    app = JobApplication.new(user: user, company_name: "Acme", job_description: body)
    assert app.valid?
    assert app.job_description_truncated?
    assert_operator app.job_description.length, :<=, Handshake::JOB_DESCRIPTION_MAX_CHARS
  end

  test "lists applications newest first" do
    user = users(:alice)
    JobApplication.where(user: user).delete_all
    older = JobApplication.create!(user: user, company_name: "OldCo", job_description: "Past")
    older.update_column(:created_at, 5.days.ago)
    newer = JobApplication.create!(user: user, company_name: "NewCo", job_description: "Now")
    newer.update_column(:created_at, Time.current)

    ids = user.job_applications.reverse_chronologically.pluck(:id)
    assert_equal [ newer.id, older.id ], ids
  end

  test "caches typst and skips LLM until the PDF compiler needs a regeneration path" do
    user = users(:alice)
    app = JobApplication.create!(user: user, company_name: "CacheCo", job_description: "Do work")
    key = user.typst_cache_key_for("CacheCo", "Do work")
    cached = "#set text(size: 9pt)[Cached CV]"
    Rails.cache.write(key, cached)

    llm_calls = 0
    user.define_singleton_method(:synthesize_typst_for_resume!) do |**|
      llm_calls += 1
      "#fresh"
    end

    fake_pdf = "%PDF-1.3\n1 0 obj<<>>endobj trailer<<>>\n%%EOF"
    app.define_singleton_method(:compile_pdf_bytes!) { |**| [ fake_pdf, cached ] }

    app.generate_resume!
    assert_equal 0, llm_calls
    app.reload
    assert_equal cached, app.generated_typst
    assert app.pdf.attached?
  end
end
