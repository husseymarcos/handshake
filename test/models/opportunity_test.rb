require "test_helper"

class OpportunityTest < ActiveSupport::TestCase
  setup do
    Current.session = professionals(:alice).sessions.create!
  end

  test "opportunities are tracked with the newest first" do
    professionals(:alice).opportunities.destroy_all
    older = professionals(:alice).opportunities.create!(organization_name: "OldCo", posting: "Past")
    older.update_column(:created_at, 5.days.ago)
    newer = professionals(:alice).opportunities.create!(organization_name: "NewCo", posting: "Now")
    newer.update_column(:created_at, Time.current)

    ids = professionals(:alice).opportunities.reverse_chronologically.pluck(:id)
    assert_equal [ newer.id, older.id ], ids
  end

  test "adapting a resume attaches a PDF to the opportunity" do
    opp = professionals(:alice).opportunities.create!(organization_name: "Acme", posting: "A posting")

    with_fake_resume_generation do
      opp.adapt!
    end

    assert opp.pdf.attached?
  end
end
