require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  test "guests are redirected away from the library" do
    get user_url(users(:alice))
    assert_redirected_to new_session_url
  end

  test "sign in reaches the library" do
    post session_url, params: { session: { email: users(:alice).email, password: "secret12" } }
    assert_redirected_to user_url(users(:alice))
    follow_redirect!
    assert_response :success
  end

  test "sign up creates a user and session" do
    assert_difference -> { User.count }, +1 do
      post users_url, params: {
        user: {
          email: "newbie@example.com",
          password: "secret12",
          password_confirmation: "secret12"
        }
      }
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
end
