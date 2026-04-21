module SessionTestHelper
  def sign_in_as(user, password: "secret12")
    post session_url, params: { session: { email: user.email, password: password } }
    assert_redirected_to root_url
    follow_redirect!
  end
end
