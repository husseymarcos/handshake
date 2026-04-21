class Capability < ApplicationRecord
  belongs_to :professional

  validates :name, presence: true

  scope :alphabetically, -> { order("LOWER(name)") }
end
