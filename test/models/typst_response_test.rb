require "test_helper"

class TypstResponseTest < ActiveSupport::TestCase
  test "extracts typst code from fenced block with language" do
    raw = "```typst\n#set text[Hello]\n```"

    result = TypstResponse.extract(raw)

    assert_equal "#set text[Hello]", result
  end

  test "extracts typst code from fenced block without language" do
    raw = "```\n#set text[Hello]\n```"

    result = TypstResponse.extract(raw)

    assert_equal "#set text[Hello]", result
  end

  test "returns raw content when no fences present" do
    raw = "#set text[Hello]"

    result = TypstResponse.extract(raw)

    assert_equal "#set text[Hello]", result
  end

  test "strips leading and trailing whitespace" do
    raw = "  \n  ```typst\n#set text[Hello]\n```  \n  "

    result = TypstResponse.extract(raw)

    assert_equal "#set text[Hello]", result
  end

  test "handles empty string" do
    result = TypstResponse.extract("")

    assert_equal "", result
  end

  test "handles nil input" do
    result = TypstResponse.extract(nil)

    assert_equal "", result
  end

  test "handles content with backticks inside" do
    raw = "```typst\n#set text[`code`]\n```"

    result = TypstResponse.extract(raw)

    assert_equal "#set text[`code`]", result
  end

  test "handles multiline content" do
    raw = "```typst\n#set text[Hello]\n#set page[A4]\n```"

    result = TypstResponse.extract(raw)

    assert_includes result, "#set text[Hello]"
    assert_includes result, "#set page[A4]"
  end

  test "handles content that starts with backticks but has no closing" do
    raw = "```typst\n#set text[Hello]"

    result = TypstResponse.extract(raw)

    assert_equal "#set text[Hello]", result
  end

  test "handles non-string input by converting to string" do
    raw = 12345

    result = TypstResponse.extract(raw)

    assert_equal "12345", result
  end
end
