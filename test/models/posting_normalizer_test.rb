require "test_helper"

class PostingNormalizerTest < ActiveSupport::TestCase
  test "returns original posting when under token limit" do
    normalizer = PostingNormalizer.new("Short job description")
    posting, truncated = normalizer.normalize

    assert_equal "Short job description", posting
    assert_not truncated
  end

  test "truncates posting and marks truncated when over token limit" do
    long_posting = "A" * (PostingNormalizer::JOB_DESCRIPTION_MAX_CHARS + 100)
    normalizer = PostingNormalizer.new(long_posting)
    posting, truncated = normalizer.normalize

    assert truncated
    assert posting.length <= PostingNormalizer::JOB_DESCRIPTION_MAX_CHARS
  end

  test "handles nil posting gracefully" do
    normalizer = PostingNormalizer.new(nil)
    posting, truncated = normalizer.normalize

    assert_nil posting
    assert_not truncated
  end

  test "handles empty posting gracefully" do
    normalizer = PostingNormalizer.new("")
    posting, truncated = normalizer.normalize

    assert_equal "", posting
    assert_not truncated
  end
end
