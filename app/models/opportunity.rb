class Opportunity < ApplicationRecord
  include ResumeGeneratable
  include Searchable

  search_by :organization_name, :posting

  belongs_to :professional
  has_one_attached :pdf

  validates :organization_name, presence: true
  validates :posting, presence: true

  scope :reverse_chronologically, -> { order(created_at: :desc) }
end
