require "test_helper"

class CapabilityTest < ActiveSupport::TestCase
  setup do
    Current.session = professionals(:alice).sessions.create!
  end

  test "capabilities are listed alphabetically regardless of case" do
    professionals(:alice).capabilities.destroy_all
    professionals(:alice).capabilities.create!(name: "Zebra")
    professionals(:alice).capabilities.create!(name: "apple")
    assert_equal [ "apple", "Zebra" ], professionals(:alice).capabilities.alphabetically.pluck(:name)
  end
end
