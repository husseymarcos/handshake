require "test_helper"

class BlueprintDefaultTest < ActiveSupport::TestCase
  test "default blueprint provides valid typst markup" do
    default = Blueprint::Default.new

    assert default.content.present?
    assert_match(/#set/, default.content)
  end
end
