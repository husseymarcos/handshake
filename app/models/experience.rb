class Experience < ApplicationRecord
  belongs_to :professional

  validates :name, presence: true

  scope :chronologically, -> { order(year: :desc, created_at: :desc) }
end
