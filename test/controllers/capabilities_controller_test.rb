require "test_helper"

class CapabilitiesControllerTest < ActionDispatch::IntegrationTest
  test "adds capability for authenticated user" do
    sign_in_as(professionals(:alice))

    assert_difference("Capability.count") do
      post capabilities_path, params: { capability: { name: "TypeScript" } }
    end

    assert_redirected_to career_path
    assert professionals(:alice).capabilities.exists?(name: "TypeScript")
  end

  test "trims capability name whitespace" do
    sign_in_as(professionals(:alice))

    post capabilities_path, params: { capability: { name: "  TypeScript  " } }

    assert professionals(:alice).capabilities.exists?(name: "TypeScript")
  end

  test "rejects blank capability name" do
    sign_in_as(professionals(:alice))

    assert_no_difference("Capability.count") do
      post capabilities_path, params: { capability: { name: "" } }
    end

    assert_redirected_to career_path
  end

  test "rejects capability with only whitespace" do
    sign_in_as(professionals(:alice))

    assert_no_difference("Capability.count") do
      post capabilities_path, params: { capability: { name: "   " } }
    end

    assert_redirected_to career_path
  end

  test "removes capability for authenticated user" do
    sign_in_as(professionals(:alice))
    capability = professionals(:alice).capabilities.first

    assert_difference("Capability.count", -1) do
      delete capability_path(capability)
    end

    assert_redirected_to career_path
    assert_not Capability.exists?(capability.id)
  end

  test "returns not found when trying to remove another user's capability" do
    sign_in_as(professionals(:alice))
    bob_capability = professionals(:bob).capabilities.first

    assert_no_difference("Capability.count") do
      delete capability_path(bob_capability)
    end

    assert_response :not_found
    assert Capability.exists?(bob_capability.id)
  end

  test "redirects unauthenticated user to sign in" do
    post capabilities_path, params: { capability: { name: "TypeScript" } }

    assert_redirected_to signin_path
  end

  test "preserves referer when adding capability" do
    sign_in_as(professionals(:alice))

    post capabilities_path, params: { capability: { name: "TypeScript" } }, headers: { "HTTP_REFERER" => career_path }

    assert_redirected_to career_path
  end

  test "preserves referer when removing capability" do
    sign_in_as(professionals(:alice))
    capability = professionals(:alice).capabilities.first

    delete capability_path(capability), headers: { "HTTP_REFERER" => career_path }

    assert_redirected_to career_path
  end
end
