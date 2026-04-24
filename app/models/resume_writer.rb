class ResumeWriter
  def self.system_instructions
    Rails.root.join("config/prompts/resume_adapter_system_instructions.md").read
  end

  def initialize(professional, chat: nil)
    @professional = professional
    @chat = chat || RubyLLM.chat(model: llm_model, provider: :gemini)
  end

  def generate(organization_name:, posting:, tone: nil)
    GeneratedResume.from_response(ask_for_resume(organization_name:, posting:, tone:)).tap(&:source)
  end

  private

  attr_reader :professional, :chat

  def ask_for_resume(organization_name:, posting:, tone:)
    chat.with_instructions(self.class.system_instructions)
    chat.ask(prompt_for(organization_name:, posting:, tone:).to_s)
    chat.messages.last&.content
  end

  def llm_model
    ENV.fetch("RUBYLLM_MODEL", "gemini-2.5-flash")
  end

  def prompt_for(organization_name:, posting:, tone:)
    ResumePrompt.new(professional:, organization_name:, posting:, tone:)
  end
end
