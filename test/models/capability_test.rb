require "test_helper"

class CapabilityTest < ActiveSupport::TestCase
  test "capabilities are listed alphabetically regardless of case" do
    professionals(:alice).capabilities.destroy_all
    professionals(:alice).capabilities.create!(name: "Zebra")
    professionals(:alice).capabilities.create!(name: "apple")
    assert_equal [ "apple", "Zebra" ], professionals(:alice).capabilities.alphabetically.pluck(:name)
  end

  test "name is required" do
    capability = professionals(:alice).capabilities.build(name: nil)
    assert_not capability.valid?
    assert_includes capability.errors[:name], "can't be blank"
  end

  test "name cannot be blank" do
    capability = professionals(:alice).capabilities.build(name: "")
    assert_not capability.valid?
    assert_includes capability.errors[:name], "can't be blank"
  end

  test "name cannot be only whitespace" do
    capability = professionals(:alice).capabilities.build(name: "   ")
    assert_not capability.valid?
  end

  test "belongs to professional" do
    capability = capabilities(:ruby)
    assert_equal professionals(:alice), capability.professional
  end

  test "destroying professional destroys dependent capabilities" do
    capability = professionals(:alice).capabilities.first

    professionals(:alice).destroy

    assert_not Capability.exists?(capability.id)
  end

  test "alphabetically scope orders mixed case correctly" do
    professionals(:alice).capabilities.destroy_all
    professionals(:alice).capabilities.create!(name: "ruby")
    professionals(:alice).capabilities.create!(name: "Rails")
    professionals(:alice).capabilities.create!(name: "AWS")
    professionals(:alice).capabilities.create!(name: "docker")

    names = professionals(:alice).capabilities.alphabetically.pluck(:name)
    assert_equal [ "AWS", "docker", "Rails", "ruby" ], names
  end

  test "alphabetically scope handles special characters" do
    professionals(:alice).capabilities.destroy_all
    professionals(:alice).capabilities.create!(name: "C++")
    professionals(:alice).capabilities.create!(name: "C#")
    professionals(:alice).capabilities.create!(name: "Go")

    names = professionals(:alice).capabilities.alphabetically.pluck(:name)
    assert_equal [ "C#", "C++", "Go" ], names
  end

  test "same capability name can exist for different professionals" do
    existing_count = Capability.where(name: "Ruby Test").count

    Capability.create!(professional: professionals(:bob), name: "Ruby Test")
    Capability.create!(professional: professionals(:carol), name: "Ruby Test")

    assert_equal existing_count + 2, Capability.where(name: "Ruby Test").count
  end

  test "multiple capabilities can be created for same professional" do
    professionals(:dave).capabilities.destroy_all

    assert_difference("Capability.count", 3) do
      professionals(:dave).capabilities.create!(name: "Ruby")
      professionals(:dave).capabilities.create!(name: "Rails")
      professionals(:dave).capabilities.create!(name: "JavaScript")
    end
  end
end
