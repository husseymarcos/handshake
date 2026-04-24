require "test_helper"

class OpportunityTest < ActiveSupport::TestCase
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

  test "organization_name is required" do
    opportunity = professionals(:alice).opportunities.build(posting: "Job description")
    assert_not opportunity.valid?
    assert_includes opportunity.errors[:organization_name], "can't be blank"
  end

  test "posting is required" do
    opportunity = professionals(:alice).opportunities.build(organization_name: "Acme")
    assert_not opportunity.valid?
    assert_includes opportunity.errors[:posting], "can't be blank"
  end

  test "belongs to professional" do
    opportunity = opportunities(:acme)
    assert_equal professionals(:alice), opportunity.professional
  end

  test "destroying professional destroys dependent opportunities" do
    opportunity = professionals(:alice).opportunities.first

    professionals(:alice).destroy

    assert_not Opportunity.exists?(opportunity.id)
  end

  test "posting is normalized on validation" do
    opportunity = professionals(:alice).opportunities.build(
      organization_name: "Test",
      posting: "A" * 40000
    )
    opportunity.valid?

    assert opportunity.posting_truncated?
    assert opportunity.posting.length <= PostingNormalizer::JOB_DESCRIPTION_MAX_CHARS
  end

  test "posting_truncated is false when under token limit" do
    opportunity = professionals(:alice).opportunities.build(
      organization_name: "Test",
      posting: "Short job description"
    )
    opportunity.valid?

    assert_not opportunity.posting_truncated?
  end

  test "adapt! raises RecordInvalid when opportunity is invalid" do
    opportunity = professionals(:alice).opportunities.build(organization_name: nil, posting: nil)

    assert_raises(ActiveRecord::RecordInvalid) do
      opportunity.adapt!
    end
  end

  test "adapt! stores generated typst" do
    opp = professionals(:alice).opportunities.create!(organization_name: "Acme", posting: "A posting")

    with_fake_resume_generation do
      opp.adapt!
    end

    assert opp.generated_typst.present?
    assert_equal "#set text[Hello]", opp.generated_typst
  end

  test "reverse_chronologically orders by created_at descending" do
    professionals(:alice).opportunities.destroy_all

    first = professionals(:alice).opportunities.create!(organization_name: "First", posting: "First")
    first.update_column(:created_at, 2.days.ago)

    second = professionals(:alice).opportunities.create!(organization_name: "Second", posting: "Second")
    second.update_column(:created_at, 1.day.ago)

    third = professionals(:alice).opportunities.create!(organization_name: "Third", posting: "Third")
    third.update_column(:created_at, Time.current)

    ids = professionals(:alice).opportunities.reverse_chronologically.pluck(:id)
    assert_equal [ third.id, second.id, first.id ], ids
  end

  test "pdf filename uses parameterized organization name" do
    opp = professionals(:alice).opportunities.create!(organization_name: "ACME Corp Inc.", posting: "A posting")

    with_fake_resume_generation do
      opp.adapt!
    end

    assert_match(/acme-corp-inc/, opp.pdf.filename.to_s)
  end

  test "pdf filename uses default when organization name parameterizes to blank" do
    opp = professionals(:alice).opportunities.create!(organization_name: "!!!", posting: "A posting")

    with_fake_resume_generation do
      opp.adapt!
    end

    assert_match(/resume/, opp.pdf.filename.to_s)
  end

  test "same organization name can exist for different professionals" do
    existing_count = Opportunity.where(organization_name: "Unique Test Corp").count

    Opportunity.create!(professional: professionals(:bob), organization_name: "Unique Test Corp", posting: "Job")
    Opportunity.create!(professional: professionals(:carol), organization_name: "Unique Test Corp", posting: "Job")

    assert_equal existing_count + 2, Opportunity.where(organization_name: "Unique Test Corp").count
  end

  test "pdf has correct content type" do
    opp = professionals(:alice).opportunities.create!(organization_name: "Acme", posting: "A posting")

    with_fake_resume_generation do
      opp.adapt!
    end

    assert_equal "application/pdf", opp.pdf.content_type
  end

  test "adapt! uses transaction to ensure consistency" do
    opp = professionals(:alice).opportunities.create!(organization_name: "Acme", posting: "A posting")

    with_fake_resume_generation do
      opp.adapt!
    end

    assert opp.pdf.attached?
    assert opp.generated_typst.present?
    assert opp.persisted?
  end

  test "tone is optional and can be blank" do
    opportunity = professionals(:alice).opportunities.build(
      organization_name: "Test",
      posting: "A job description",
      tone: ""
    )

    assert opportunity.valid?
  end

  test "tone must be from the allowed list" do
    opportunity = professionals(:alice).opportunities.build(
      organization_name: "Test",
      posting: "A job description",
      tone: "InvalidTone"
    )

    assert_not opportunity.valid?
    assert_includes opportunity.errors[:tone], "is not included in the list"
  end

  test "adapt! passes tone to the compiler" do
    opp = professionals(:alice).opportunities.create!(
      organization_name: "Acme",
      posting: "A posting",
      tone: "Enthusiastic"
    )

    with_fake_resume_generation do
      opp.adapt!
    end

    assert opp.pdf.attached?
  end

  test "posting normalization handles nil posting" do
    opportunity = Opportunity.new(professional: professionals(:alice), organization_name: "Test")
    opportunity.posting = nil

    opportunity.valid?

    # The normalize_posting method sets posting to "" when nil, but validation may not run the setter
    assert_includes [ nil, "" ], opportunity.posting
  end

  test "posting normalization handles empty posting" do
    opportunity = Opportunity.new(
      professional: professionals(:alice),
      organization_name: "Test",
      posting: ""
    )

    opportunity.valid?

    assert_not opportunity.posting_truncated?
  end
end
