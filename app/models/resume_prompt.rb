class ResumePrompt
  def initialize(professional:, organization_name:, posting:, tone:)
    @professional = professional
    @organization_name = organization_name
    @posting = posting
    @tone = tone
  end

  def to_s
    <<~TXT
      Use this CV template as the structural starting point (you may reorganize for fit, but keep a professional CV):
      #{CurriculumVitae.for(professional)}

      Candidate capabilities: #{capabilities}

      Candidate experience:
      #{experience}

      Target organization: #{organization_name}
      Posting:
      #{posting}#{tone_line}
    TXT
  end

  private

  attr_reader :professional, :organization_name, :posting, :tone

  def capabilities
    professional.capabilities.alphabetically.pluck(:name).join(", ").presence || "(none yet - infer sparingly from experience)"
  end

  def experience
    professional.experiences.chronologically.map { |entry| ExperienceFormatter.new(entry).to_s }.join("\n").presence || "(none listed)"
  end

  def tone_line
    tone.present? ? "\nTone: #{tone}" : ""
  end
end
