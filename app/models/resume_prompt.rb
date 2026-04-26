class ResumePrompt
  def initialize(professional:, organization_name:, posting:)
    @professional = professional
    @organization_name = organization_name
    @posting = posting
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
      #{posting}
    TXT
  end

  private

  attr_reader :professional, :organization_name, :posting

  def capabilities
    professional.capabilities.alphabetically.pluck(:name).join(", ").presence || "(none yet - infer sparingly from experience)"
  end

  def experience
    professional.experiences.chronologically.map { |entry| ExperienceFormatter.new(entry).to_s }.join("\n").presence || "(none listed)"
  end
end
