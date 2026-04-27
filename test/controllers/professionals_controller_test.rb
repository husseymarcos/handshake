require "test_helper"

class ProfessionalsControllerTest < ActionDispatch::IntegrationTest
  test "renders sign up form for unauthenticated users" do
    get signup_path

    assert_response :success
  end

  test "creates professional with valid data and signs them in" do
    assert_difference("Professional.count") do
      post professionals_path, params: {
        professional: {
          name: "New User",
          email: "newuser@example.com",
          password: "secret12",
          password_confirmation: "secret12"
        }
      }
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "rejects professional creation with invalid email" do
    assert_no_difference("Professional.count") do
      post professionals_path, params: {
        professional: {
          name: "New User",
          email: "not-an-email",
          password: "secret12",
          password_confirmation: "secret12"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "rejects professional creation with mismatched passwords" do
    assert_no_difference("Professional.count") do
      post professionals_path, params: {
        professional: {
          name: "New User",
          email: "newuser@example.com",
          password: "secret12",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "rejects professional creation with blank password" do
    assert_no_difference("Professional.count") do
      post professionals_path, params: {
        professional: {
          name: "New User",
          email: "newuser@example.com",
          password: "",
          password_confirmation: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "rejects professional creation with duplicate email" do
    assert_no_difference("Professional.count") do
      post professionals_path, params: {
        professional: {
          name: "New User",
          email: professionals(:alice).email,
          password: "secret12",
          password_confirmation: "secret12"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "email is normalized to lowercase on creation" do
    post professionals_path, params: {
      professional: {
        name: "Upper Case",
        email: "UPPERCASE@EXAMPLE.COM",
        password: "secret12",
        password_confirmation: "secret12"
      }
    }

    professional = Professional.find_by(email: "uppercase@example.com")
    assert professional
  end

  test "shows career page for authenticated user" do
    sign_in_as(professionals(:alice))

    get career_path

    assert_response :success
  end

  test "redirects unauthenticated user from career page to sign in" do
    get career_path

    assert_redirected_to signin_path
  end

  test "renders settings page for authenticated user" do
    sign_in_as(professionals(:alice))

    get settings_path

    assert_response :success
  end

  test "updates professional email" do
    sign_in_as(professionals(:alice))

    patch professional_path(professionals(:alice)), params: {
      professional: { name: professionals(:alice).name, email: "newemail@example.com" }
    }

    assert_redirected_to career_path
    assert_equal "newemail@example.com", professionals(:alice).reload.email
  end

  test "rejects update with invalid email" do
    sign_in_as(professionals(:alice))

    patch professional_path(professionals(:alice)), params: {
      professional: { email: "invalid-email" }
    }

    assert_response :unprocessable_entity
  end

  test "rejects update with duplicate email" do
    sign_in_as(professionals(:alice))

    patch professional_path(professionals(:alice)), params: {
      professional: { email: professionals(:bob).email }
    }

    assert_response :unprocessable_entity
  end

  test "returns not found when viewing another user's profile" do
    sign_in_as(professionals(:alice))

    get professional_path(professionals(:bob))

    assert_response :not_found
  end

  test "prevents editing another user's profile" do
    sign_in_as(professionals(:alice))

    get edit_professional_path(professionals(:bob))

    assert_redirected_to career_path
  end

  test "prevents updating another user's profile" do
    sign_in_as(professionals(:alice))

    patch professional_path(professionals(:bob)), params: {
      professional: { email: "hacked@example.com" }
    }

    assert_redirected_to career_path
    assert_equal professionals(:bob).email, professionals(:bob).reload.email
  end
end
