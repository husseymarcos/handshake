require "test_helper"

class Opportunities::DownloadsControllerTest < ActionDispatch::IntegrationTest
  test "downloads PDF for user's opportunity" do
    sign_in_as(professionals(:alice))
    opportunity = opportunities(:acme)

    with_fake_resume_generation do
      opportunity.adapt!
    end

    get opportunity_download_path(opportunity)

    assert_response :success
    assert_equal "application/pdf", response.content_type
  end

  test "returns not found when PDF is not attached" do
    sign_in_as(professionals(:alice))
    opportunity = opportunities(:acme)
    opportunity.pdf.detach if opportunity.pdf.attached?

    get opportunity_download_path(opportunity)

    assert_response :not_found
  end

  test "returns not found when downloading another user's PDF" do
    sign_in_as(professionals(:alice))
    bob_opportunity = opportunities(:startup_co)

    get opportunity_download_path(bob_opportunity)

    assert_response :not_found
  end

  test "redirects unauthenticated user to sign in" do
    opportunity = opportunities(:acme)

    get opportunity_download_path(opportunity)

    assert_redirected_to signin_path
  end
end
