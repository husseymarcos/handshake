module Skillable
  extend ActiveSupport::Concern

  included do
    has_many :skills, dependent: :destroy
  end

  def add_skill(name)
    skills.create!(name: name.to_s.strip)
  end

  def remove_skill(skill)
    skill.destroy! if owns?(skill)
  end

  def owns?(resource)
    resource.respond_to?(:user_id) && resource.user_id == id
  end
end
