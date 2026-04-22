require "test_helper"

class CurriculumVitaeDefaultTest < ActiveSupport::TestCase
  test "default curriculum vitae provides valid typst markup" do
    default = CurriculumVitae::Default.new

    assert default.content.present?
    assert_match(/#set/, default.content)
  end
end
