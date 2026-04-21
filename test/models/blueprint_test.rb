require "test_helper"

class BlueprintTest < ActiveSupport::TestCase
  test "reads body from default typst file" do
    Blueprint.clear_cache

    body = Blueprint.body

    assert body.present?
    assert_match(/#set/, body)
  end

  test "caches body after first read" do
    Blueprint.clear_cache

    body1 = Blueprint.body
    body2 = Blueprint.body

    assert_equal body1.object_id, body2.object_id
  end

  test "clear_cache removes cached body" do
    Blueprint.clear_cache
    original_body = Blueprint.body

    Blueprint.clear_cache
    new_body = Blueprint.body

    assert_equal original_body, new_body
  end

  test "default path points to config directory" do
    assert_equal Rails.root.join("config/default.typst"), Blueprint::DEFAULT_PATH
  end

  test "default typst file exists" do
    assert File.exist?(Blueprint::DEFAULT_PATH), "Default typst file should exist at #{Blueprint::DEFAULT_PATH}"
  end
end
