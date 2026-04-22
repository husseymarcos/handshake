require "test_helper"

class CapabilityTest < ActiveSupport::TestCase
  setup do
    @alice = professionals(:alice)
    @bob = professionals(:bob)
    @carol = professionals(:carol)
    @dave = professionals(:dave)
  end

  test "a capability knows its professional" do
    capability = capabilities(:ruby)

    assert_equal @alice, capability.professional
  end

  test "a capability requires a name" do
    capability_without_name = Capability.new(professional: @alice, name: nil)
    capability_with_blank_name = Capability.new(professional: @alice, name: "")
    capability_with_whitespace_name = Capability.new(professional: @alice, name: "   ")

    assert_not capability_without_name.valid?
    assert_not capability_with_blank_name.valid?
    assert_not capability_with_whitespace_name.valid?
  end

  test "different professionals can share the same capability name" do
    shared_name = "Ruby Test"

    Capability.create!(professional: @bob, name: shared_name)
    Capability.create!(professional: @carol, name: shared_name)

    bob_has_capability = @bob.capabilities.exists?(name: shared_name)
    carol_has_capability = @carol.capabilities.exists?(name: shared_name)

    assert bob_has_capability
    assert carol_has_capability
  end

  test "a professional can have many capabilities" do
    @dave.capabilities.destroy_all
    @dave.capabilities.create!(name: "Ruby")
    @dave.capabilities.create!(name: "Rails")
    @dave.capabilities.create!(name: "JavaScript")

    dave_capabilities = @dave.capabilities.pluck(:name)

    assert_includes dave_capabilities, "Ruby"
    assert_includes dave_capabilities, "Rails"
    assert_includes dave_capabilities, "JavaScript"
  end

  test "deleting a professional removes their capabilities" do
    capability = @alice.capabilities.first

    @alice.destroy

    assert_not Capability.exists?(capability.id)
  end
end
