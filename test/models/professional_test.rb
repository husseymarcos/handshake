require "test_helper"

class ProfessionalTest < ActiveSupport::TestCase
  setup do
    Current.session = professionals(:alice).sessions.create!
  end

  test "a professional can add capabilities to their portfolio" do
    professionals(:alice).capabilities.destroy_all
    professionals(:alice).add_capability("TypeScript")
    assert_equal [ "TypeScript" ], professionals(:alice).capabilities.alphabetically.pluck(:name)
  end

  test "a professional can only manage their own portfolio assets" do
    capability = professionals(:bob).capabilities.create!(name: "Python")
    assert_not professionals(:alice).owns?(capability)
    assert professionals(:alice).owns?(professionals(:alice).capabilities.first)
  end
end
