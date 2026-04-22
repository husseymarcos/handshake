require "test_helper"

class BlueprintTest < ActiveSupport::TestCase
  test "blueprint provides typst content for resume generation" do
    blueprint = Blueprint.for(professionals(:alice))

    assert blueprint.content.present?
    assert_match(/#set/, blueprint.content)
  end

  test "blueprints can use different content sources" do
    custom_source = Struct.new(:content).new("custom typst")
    blueprint = Blueprint.new(custom_source)

    assert_equal "custom typst", blueprint.content
  end
end
