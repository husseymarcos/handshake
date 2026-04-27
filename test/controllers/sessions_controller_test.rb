require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "renders sign in form for unauthenticated users" do
    get signin_path

    assert_response :success
  end

  test "creates session with valid credentials" do
    post session_path, params: { session: { email: professionals(:alice).email, password: "secret12" } }

    assert_redirected_to root_url
    follow_redirect!
    assert_response :success
  end

  test "rejects invalid email" do
    post session_path, params: { session: { email: "wrong@example.com", password: "secret12" } }

    assert_response :unprocessable_entity
  end

  test "rejects invalid password" do
    post session_path, params: { session: { email: professionals(:alice).email, password: "wrongpassword" } }

    assert_response :unprocessable_entity
  end

  test "rejects blank credentials" do
    post session_path, params: { session: { email: "", password: "" } }

    assert_response :unprocessable_entity
  end

  test "email is case insensitive during sign in" do
    post session_path, params: { session: { email: professionals(:alice).email.upcase, password: "secret12" } }

    assert_redirected_to root_url
  end

  test "email is trimmed during sign in" do
    post session_path, params: { session: { email: "  #{professionals(:alice).email}  ", password: "secret12" } }

    assert_redirected_to root_url
  end

  test "destroys session on sign out" do
    sign_in_as(professionals(:alice))

    delete session_path

    assert_redirected_to signin_path
  end
end
