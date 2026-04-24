class ResumeAdapter
  class Error < StandardError; end
  class MissingApiKeyError < Error; end
  class EmptyResponseError < Error; end

  def initialize(professional)
    @professional = professional
  end

  def adapt(organization_name:, posting:, tone: nil, refinement: nil)
    ensure_api_key!

    response = generate_typst(organization_name, posting, tone, refinement)
    TypstResponse.extract(response)
  end

  def cache_key_for(organization_name, posting)
    payload = [ professional.id, organization_name.to_s, posting.to_s ].join(":")
    "handshake/resume_typst/v2/#{Digest::SHA256.hexdigest(payload)}"
  end

  private

  attr_reader :professional

  def ensure_api_key!
    return if ENV["GEMINI_API_KEY"].to_s.strip.present?

    raise MissingApiKeyError, "GEMINI_API_KEY is not set"
  end

  def generate_typst(organization_name, posting, tone, refinement)
    chat = RubyLLM.chat(model: llm_model, provider: :gemini)
    chat.with_instructions(system_instruction)
    chat.ask(user_prompt(organization_name, posting, tone, refinement))

    content = chat.messages.last&.content
    raise EmptyResponseError, "empty model response" if content.blank?

    content
  end

  def llm_model
    ENV.fetch("RUBYLLM_MODEL", "gemini-2.5-flash")
  end

  def system_instruction
    <<~TXT
      You write Typst source for a CV that must compile with the official Typst CLI.
      Output must be ONLY valid Typst — no markdown fences, no commentary.
      The final PDF must be a single letter/A4 page: be concise and avoid overflow.
    TXT
  end

  def user_prompt(organization_name, posting, tone, refinement)
    capability_line = professional.capabilities.alphabetically.pluck(:name).join(", ")
    experience_block = professional.experiences.chronologically.map { |e| experience_bullet(e) }.join("\n")

    <<~TXT
      Use this CV template as the structural starting point (you may reorganize for fit, but keep a professional CV):
      #{CurriculumVitae.for(professional)}

      Candidate capabilities: #{capability_line.presence || "(none yet — infer sparingly from experience)"}

      Candidate experience:
      #{experience_block.presence || "(none listed)"}

      Target organization: #{organization_name}
      Posting:
      #{posting}
      #{tone.present? ? "\nTone: #{tone}" : ""}
      #{refinement.present? ? "\nLayout constraint: #{refinement}" : ""}
    TXT
  end

  def experience_bullet(experience)
    parts = [ "*#{experience.name}*" ]
    parts << "(#{experience.year})" if experience.year.present?
    parts << "— #{experience.title}" if experience.title.present?
    parts << "— #{experience.description}" if experience.description.present?
    parts << "[#{experience.stack}]" if experience.stack.present?
    parts << "(#{experience.github_url})" if experience.github_url.present?
    parts.join(" ")
  end
end
