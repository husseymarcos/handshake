require "test_helper"

class ExperiencesControllerTest < ActionDispatch::IntegrationTest
  test "renders new experience form" do
    sign_in_as(professionals(:alice))

    get new_experience_path

    assert_response :success
  end

  test "creates experience with all fields" do
    sign_in_as(professionals(:alice))

    assert_difference("Experience.count") do
      post experiences_path, params: {
        experience: {
          name: "New Project",
          year: 2024,
          title: "Lead Developer",
          description: "A great project",
          stack: "Ruby, Rails",
          github_url: "https://github.com/example/project"
        }
      }
    end

    assert_redirected_to career_path

    experience = professionals(:alice).experiences.find_by(name: "New Project")
    assert experience
    assert_equal 2024, experience.year
    assert_equal "Lead Developer", experience.title
  end

  test "creates experience with only required fields" do
    sign_in_as(professionals(:alice))

    assert_difference("Experience.count") do
      post experiences_path, params: {
        experience: { name: "Minimal Project" }
      }
    end

    assert_redirected_to career_path
    experience = professionals(:alice).experiences.find_by(name: "Minimal Project")
    assert experience
    assert_nil experience.year
  end

  test "rejects experience without name" do
    sign_in_as(professionals(:alice))

    assert_no_difference("Experience.count") do
      post experiences_path, params: {
        experience: { name: "", year: 2024 }
      }
    end

    assert_response :unprocessable_entity
  end

  test "renders edit form for user's experience" do
    sign_in_as(professionals(:alice))
    experience = professionals(:alice).experiences.first

    get edit_experience_path(experience)

    assert_response :success
  end

  test "updates experience" do
    sign_in_as(professionals(:alice))
    experience = professionals(:alice).experiences.first

    patch experience_path(experience), params: {
      experience: { name: "Updated Name", year: 2025 }
    }

    assert_redirected_to career_path
    assert_equal "Updated Name", experience.reload.name
    assert_equal 2025, experience.year
  end

  test "rejects update with blank name" do
    sign_in_as(professionals(:alice))
    experience = professionals(:alice).experiences.first

    patch experience_path(experience), params: {
      experience: { name: "" }
    }

    assert_response :unprocessable_entity
    assert_not_equal "", experience.reload.name
  end

  test "destroys experience" do
    sign_in_as(professionals(:alice))
    experience = professionals(:alice).experiences.first

    assert_difference("Experience.count", -1) do
      delete experience_path(experience)
    end

    assert_redirected_to career_path
    assert_not Experience.exists?(experience.id)
  end

  test "returns not found when accessing another user's experience" do
    sign_in_as(professionals(:alice))
    bob_experience = professionals(:bob).experiences.first

    get experience_path(bob_experience)

    assert_response :not_found
  end

  test "returns not found when editing another user's experience" do
    sign_in_as(professionals(:alice))
    bob_experience = professionals(:bob).experiences.first

    get edit_experience_path(bob_experience)

    assert_response :not_found
  end

  test "returns not found when updating another user's experience" do
    sign_in_as(professionals(:alice))
    bob_experience = professionals(:bob).experiences.first
    original_name = bob_experience.name

    patch experience_path(bob_experience), params: {
      experience: { name: "Hacked Name" }
    }

    assert_response :not_found
    assert_equal original_name, bob_experience.reload.name
  end

  test "returns not found when destroying another user's experience" do
    sign_in_as(professionals(:alice))
    bob_experience = professionals(:bob).experiences.first

    assert_no_difference("Experience.count") do
      delete experience_path(bob_experience)
    end

    assert_response :not_found
    assert Experience.exists?(bob_experience.id)
  end

  test "redirects unauthenticated user to sign in" do
    get new_experience_path

    assert_redirected_to signin_path
  end
end
