class User < ApplicationRecord
  DEFAULT_BLUEPRINT_PATH = Rails.root.join("config/default.typst")

  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :skills, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :opportunities, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :blueprint_updated_at, presence: true

  before_validation :normalize_email
  before_validation :ensure_blueprint_timestamp, on: :create

  def add_skill(name)
    skills.create!(name: name.to_s.strip)
  end

  def remove_skill(skill)
    skill.destroy! if skill.user_id == id
  end

  def touch_blueprint!(typst)
    update(blueprint_typst: typst, blueprint_updated_at: Time.current)
  end

  def blueprint_body
    blueprint_typst.presence || self.class.default_blueprint
  end

  def self.default_blueprint
    @default_blueprint ||= File.read(DEFAULT_BLUEPRINT_PATH)
  end

  def synthesize_typst_for_resume!(company_name:, job_description:, refinement: nil)
    if ENV["GEMINI_API_KEY"].to_s.strip.empty?
      raise RubyLLM::Error, "GEMINI_API_KEY is not set"
    end

    chat = RubyLLM.chat(model: Handshake.llm_model, provider: :gemini)
    chat.with_instructions(resume_system_instruction)
    chat.ask(resume_user_prompt(company_name, job_description, refinement))
    last = chat.messages.last
    content = last&.content
    raise RubyLLM::Error, "empty model response" if content.blank?

    TypstResponse.extract(content)
  end

  def typst_cache_key_for(company_name, job_description)
    payload = [ id, company_name.to_s, job_description.to_s, blueprint_updated_at.to_f ].join(":")
    "handshake/resume_typst/v1/#{Digest::SHA256.hexdigest(payload)}"
  end

  def can_edit?(resource)
    resource.respond_to?(:user_id) && resource.user_id == id
  end

  private

    def normalize_email
      self.email = email.to_s.downcase.strip
    end

    def ensure_blueprint_timestamp
      self.blueprint_updated_at ||= Time.current
    end

    def resume_system_instruction
      <<~TXT
        You write Typst source for a CV that must compile with the official Typst CLI.
        Output must be ONLY valid Typst — no markdown fences, no commentary.
        The final PDF must be a single letter/A4 page: be concise and avoid overflow.
      TXT
    end

    def resume_user_prompt(company_name, job_description, refinement)
      skill_line = skills.alphabetically.pluck(:name).join(", ")
      project_block = projects.chronologically.map { |p| project_bullet(p) }.join("\n")

      <<~TXT
        Use this blueprint as the structural starting point (you may reorganize for fit, but keep a professional CV):
        #{blueprint_body}

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
