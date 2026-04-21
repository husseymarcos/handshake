require "test_helper"

class ExperienceTest < ActiveSupport::TestCase
  setup do
    Current.session = professionals(:alice).sessions.create!
  end

  test "experience is showcased with the newest first" do
    professionals(:alice).experiences.destroy_all
    older = professionals(:alice).experiences.create!(name: "Older Experience", year: 2020)
    newer = professionals(:alice).experiences.create!(name: "Newer Experience", year: 2024)
    assert_equal [ newer.id, older.id ], professionals(:alice).experiences.chronologically.pluck(:id)
  end

  test "undated experience appears after dated experience" do
    professionals(:alice).experiences.destroy_all
    dated = professionals(:alice).experiences.create!(name: "Dated", year: 2024)
    undated = professionals(:alice).experiences.create!(name: "Undated")
    assert_equal [ dated.id, undated.id ], professionals(:alice).experiences.chronologically.pluck(:id)
  end
end
