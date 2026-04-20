require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "add_skill stores a normalized skill" do
    user = users(:alice)
    user.skills.destroy_all
    user.add_skill("  Typst ")
    assert_equal [ "Typst" ], user.skills.alphabetically.pluck(:name)
  end

  test "owns? returns true for resources belonging to user" do
    user = users(:alice)
    skill = user.skills.create!(name: "Ruby")
    assert user.owns?(skill)
  end

  test "owns? returns false for resources belonging to other users" do
    alice = users(:alice)
    bob = users(:bob)
    skill = bob.skills.create!(name: "Ruby")
    assert_not alice.owns?(skill)
  end
end
