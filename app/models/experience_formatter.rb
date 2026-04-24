class ExperienceFormatter
  def initialize(experience)
    @experience = experience
  end

  def to_s
    parts.join(" ")
  end

  private

  attr_reader :experience

  def parts
    [ name, year, title, description, stack, github_url ].compact
  end

  def name
    "*#{experience.name}*"
  end

  def year
    "(#{experience.year})" if experience.year.present?
  end

  def title
    "— #{experience.title}" if experience.title.present?
  end

  def description
    "— #{experience.description}" if experience.description.present?
  end

  def stack
    "[#{experience.stack}]" if experience.stack.present?
  end

  def github_url
    "(#{experience.github_url})" if experience.github_url.present?
  end
end
