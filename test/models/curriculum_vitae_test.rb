require "test_helper"

class CurriculumVitaeTest < ActiveSupport::TestCase
  test "curriculum vitae provides typst content for resume generation" do
    cv_content = CurriculumVitae.for(professionals(:alice))

    assert cv_content.present?
    assert_match(/#set/, cv_content)
  end
end
