require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "add_skill stores a normalized skill" do
    user = users(:alice)
    user.skills.destroy_all
    user.add_skill("  Typst ")
    assert_equal [ "Typst" ], user.skills.alphabetically.pluck(:name)
  end

  test "typst cache key changes after blueprint timestamp updates" do
    user = users(:alice)
    key_before = user.typst_cache_key_for("Co", "job")
    user.update!(blueprint_updated_at: 3.days.from_now)
    key_after = user.typst_cache_key_for("Co", "job")
    assert_not_equal key_before, key_after
  end
end
