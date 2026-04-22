require "test_helper"

class Capability::AlphabeticalOrderingTest < ActiveSupport::TestCase
  setup do
    @alice = professionals(:alice)
    @alice.capabilities.destroy_all
  end

  test "ignores case when ordering" do
    @alice.capabilities.create!(name: "Zebra")
    @alice.capabilities.create!(name: "apple")

    names = @alice.capabilities.alphabetically.pluck(:name)

    assert_equal [ "apple", "Zebra" ], names
  end

  test "orders mixed case correctly" do
    @alice.capabilities.create!(name: "ruby")
    @alice.capabilities.create!(name: "Rails")
    @alice.capabilities.create!(name: "AWS")
    @alice.capabilities.create!(name: "docker")

    names = @alice.capabilities.alphabetically.pluck(:name)

    assert_equal [ "AWS", "docker", "Rails", "ruby" ], names
  end

  test "handles special characters" do
    @alice.capabilities.create!(name: "C++")
    @alice.capabilities.create!(name: "C#")
    @alice.capabilities.create!(name: "Go")

    names = @alice.capabilities.alphabetically.pluck(:name)

    assert_equal [ "C#", "C++", "Go" ], names
  end
end
