class Opportunity < ApplicationRecord
  include ToneSelectable
  include ResumeGeneratable

  belongs_to :professional
  has_one_attached :pdf

  validates :organization_name, presence: true
  validates :posting, presence: true

  scope :reverse_chronologically, -> { order(created_at: :desc) }
end
