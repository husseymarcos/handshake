class PostingNormalizer
  JOB_DESCRIPTION_MAX_TOKENS = 8000
  JOB_DESCRIPTION_MAX_CHARS  = JOB_DESCRIPTION_MAX_TOKENS * 4

  def self.estimate_tokens(text)
    (text.to_s.length / 4.0).ceil
  end

  def initialize(posting)
    @posting = posting
  end

  def normalize
    text = @posting.to_s

    if exceeds_token_limit?(text)
      [ truncate(text), true ]
    else
      [ @posting, false ]
    end
  end

  private

  def exceeds_token_limit?(text)
    self.class.estimate_tokens(text) > JOB_DESCRIPTION_MAX_TOKENS
  end

  def truncate(text)
    text.truncate(JOB_DESCRIPTION_MAX_CHARS, omission: "")
  end
end
