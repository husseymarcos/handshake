require "test_helper"

class OpportunitiesControllerTest < ActionDispatch::IntegrationTest
  test "lists opportunities for authenticated user" do
    sign_in_as(professionals(:alice))

    get opportunities_path

    assert_response :success
  end

  test "opportunities are ordered with newest first" do
    sign_in_as(professionals(:alice))

    get opportunities_path

    assert_response :success
  end

  test "renders new opportunity form with tone select" do
    sign_in_as(professionals(:alice))

    get new_opportunity_path

    assert_response :success
    assert_select "form[action='#{opportunities_path}']"
    assert_select "input[name='opportunity[organization_name]']"
    assert_select "textarea[name='opportunity[posting]']"
    assert_select "select[name='opportunity[tone]']"
  end

  test "renders new opportunity form" do
    sign_in_as(professionals(:alice))

    get new_opportunity_path

    assert_response :success
    assert_select "form[action='#{opportunities_path}']"
    assert_select "input[name='opportunity[organization_name]']"
    assert_select "textarea[name='opportunity[posting]']"
  end

  test "creates opportunity with tone and generates resume" do
    sign_in_as(professionals(:alice))

    with_fake_resume_generation do
      assert_difference("Opportunity.count") do
        post opportunities_path, params: {
          opportunity: {
            organization_name: "Tone Corp",
            posting: "Looking for a Ruby developer",
            tone: "Enthusiastic"
          }
        }
      end
    end

    assert_redirected_to opportunity_path(Opportunity.last)

    opportunity = professionals(:alice).opportunities.find_by(organization_name: "Tone Corp")
    assert_equal "Enthusiastic", opportunity.tone
    assert opportunity.pdf.attached?
  end

  test "creates opportunity and generates resume" do
    sign_in_as(professionals(:alice))

    with_fake_resume_generation do
      assert_difference("Opportunity.count") do
        post opportunities_path, params: {
          opportunity: {
            organization_name: "New Corp",
            posting: "Looking for a Ruby developer"
          }
        }
      end
    end

    assert_redirected_to opportunity_path(Opportunity.last)

    opportunity = professionals(:alice).opportunities.find_by(organization_name: "New Corp")
    assert opportunity
    assert opportunity.pdf.attached?
  end

  test "rejects opportunity without organization name" do
    sign_in_as(professionals(:alice))

    assert_no_difference("Opportunity.count") do
      post opportunities_path, params: {
        opportunity: {
          organization_name: "",
          posting: "Looking for a developer"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "rejects opportunity without posting" do
    sign_in_as(professionals(:alice))

    assert_no_difference("Opportunity.count") do
      post opportunities_path, params: {
        opportunity: {
          organization_name: "New Corp",
          posting: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "shows opportunity with download link when PDF exists" do
    sign_in_as(professionals(:alice))
    opportunity = opportunities(:acme)

    with_fake_resume_generation do
      opportunity.adapt!
    end

    get opportunity_path(opportunity)

    assert_response :success
    assert_select "a[href='#{opportunity_download_path(opportunity)}']"
  end

  test "shows opportunity without download link when PDF is missing" do
    sign_in_as(professionals(:alice))
    opportunity = opportunities(:acme)
    opportunity.pdf.detach if opportunity.pdf.attached?

    get opportunity_path(opportunity)

    assert_response :success
    assert_select "a[href='#{opportunity_download_path(opportunity)}']", count: 0
  end

  test "returns not found when viewing another user's opportunity" do
    sign_in_as(professionals(:alice))
    bob_opportunity = opportunities(:startup_co)

    get opportunity_path(bob_opportunity)

    assert_response :not_found
  end

  test "redirects unauthenticated user to sign in" do
    get opportunities_path

    assert_redirected_to signin_path
  end

  test "normalizes organization name in filename" do
    sign_in_as(professionals(:alice))

    with_fake_resume_generation do
      post opportunities_path, params: {
        opportunity: {
          organization_name: "ACME Corp Inc.",
          posting: "Job description"
        }
      }
    end

    opportunity = Opportunity.last
    assert_match(/acme-corp-inc/, opportunity.pdf.filename.to_s)
  end

  test "uses default filename when organization name is empty after parameterization" do
    sign_in_as(professionals(:alice))

    with_fake_resume_generation do
      post opportunities_path, params: {
        opportunity: {
          organization_name: "!!!",
          posting: "Job description"
        }
      }
    end

    opportunity = Opportunity.last
    assert_match(/resume/, opportunity.pdf.filename.to_s)
  end
end
