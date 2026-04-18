require "test_helper"

class ResumeCacheInvalidationTest < ActionDispatch::IntegrationTest
  test "blueprint updates change the resume cache key" do
    user = users(:alice)
    sign_in_as user
    key_before = user.typst_cache_key_for("Co", "desc")
    patch user_url(user), params: { user: { blueprint_typst: "updated typst" } }
    assert_redirected_to user_url(user)
    user.reload
    key_after = user.typst_cache_key_for("Co", "desc")
    assert_not_equal key_before, key_after
  end
end
