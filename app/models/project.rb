class Project < ApplicationRecord
  belongs_to :user

  validates :name, presence: true

  scope :chronologically, -> { order(year: :desc, created_at: :desc) }
end
