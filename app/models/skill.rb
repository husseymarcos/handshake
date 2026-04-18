class Skill < ApplicationRecord
  belongs_to :user

  validates :name, presence: true

  scope :alphabetically, -> { order("LOWER(name)") }
end
