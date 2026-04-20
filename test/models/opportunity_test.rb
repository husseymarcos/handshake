require "test_helper"

class OpportunityTest < ActiveSupport::TestCase
  test "truncates job descriptions that exceed the token budget" do
    user = users(:alice)
    Opportunity.where(user: user).delete_all
    body = "x" * (Handshake::JOB_DESCRIPTION_MAX_CHARS + 500)
    opp = Opportunity.create!(user: user, company_name: "Acme", job_description: body)
    # NOTE: opp.valid? is already called by create!, don't call it again
    # or the truncated flag will reset since the text is already truncated
    assert opp.job_description_truncated?
    assert_operator opp.job_description.length, :<=, Handshake::JOB_DESCRIPTION_MAX_CHARS
  end

  test "lists opportunities newest first" do
    user = users(:alice)
    Opportunity.where(user: user).delete_all
    older = Opportunity.create!(user: user, company_name: "OldCo", job_description: "Past")
    older.update_column(:created_at, 5.days.ago)
    newer = Opportunity.create!(user: user, company_name: "NewCo", job_description: "Now")
    newer.update_column(:created_at, Time.current)

    ids = user.opportunities.reverse_chronologically.pluck(:id)
    assert_equal [ newer.id, older.id ], ids
  end
end
