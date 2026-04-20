class User::ResumeSynthesizer
  class Error < StandardError; end
  class MissingApiKeyError < Error; end
  class EmptyResponseError < Error; end

  def initialize(user)
    @user = user
  end

  def synthesize(company_name:, job_description:, refinement: nil)
    ensure_api_key!

    response = generate_typst(company_name, job_description, refinement)
    TypstResponse.extract(response)
  end

  def cache_key_for(company_name, job_description)
    payload = [ user.id, company_name.to_s, job_description.to_s ].join(":")
    "handshake/resume_typst/v2/#{Digest::SHA256.hexdigest(payload)}"
  end

  private

  attr_reader :user

  def ensure_api_key!
    return if ENV["GEMINI_API_KEY"].to_s.strip.present?

    raise MissingApiKeyError, "GEMINI_API_KEY is not set"
  end

  def generate_typst(company_name, job_description, refinement)
    chat = RubyLLM.chat(model: Handshake.llm_model, provider: :gemini)
    chat.with_instructions(system_instruction)
    chat.ask(user_prompt(company_name, job_description, refinement))

    content = chat.messages.last&.content
    raise EmptyResponseError, "empty model response" if content.blank?

    content
  end

  def system_instruction
    <<~TXT
      You write Typst source for a CV that must compile with the official Typst CLI.
      Output must be ONLY valid Typst — no markdown fences, no commentary.
      The final PDF must be a single letter/A4 page: be concise and avoid overflow.
    TXT
  end

  def user_prompt(company_name, job_description, refinement)
    skill_line = user.skills.alphabetically.pluck(:name).join(", ")
    project_block = user.projects.chronologically.map { |p| project_bullet(p) }.join("\n")

    <<~TXT
      Use this blueprint as the structural starting point (you may reorganize for fit, but keep a professional CV):
      #{Blueprint.body}

      Candidate skills: #{skill_line.presence || "(none yet — infer sparingly from projects)"}

      Candidate projects:
      #{project_block.presence || "(none listed)"}

      Target company: #{company_name}
      Job description:
      #{job_description}
      #{refinement.present? ? "\nLayout constraint: #{refinement}" : ""}
    TXT
  end

  def project_bullet(project)
    parts = [ "*#{project.name}*" ]
    parts << "(#{project.year})" if project.year.present?
    parts << "— #{project.title}" if project.title.present?
    parts << "— #{project.description}" if project.description.present?
    parts << "[#{project.stack}]" if project.stack.present?
    parts << "(#{project.github_url})" if project.github_url.present?
    parts.join(" ")
  end
end
