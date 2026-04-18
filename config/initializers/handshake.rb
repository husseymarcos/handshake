module Handshake
  module_function

  def llm_model
    ENV.fetch("RUBYLLM_MODEL", "gemini-2.5-flash")
  end

  JOB_DESCRIPTION_MAX_TOKENS = 8000
  JOB_DESCRIPTION_MAX_CHARS  = JOB_DESCRIPTION_MAX_TOKENS * 4

  def estimate_tokens(text)
    (text.to_s.length / 4.0).ceil
  end
end
