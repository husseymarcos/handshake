class Professional < ApplicationRecord
  include Capable

  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :experiences, dependent: :destroy
  has_many :opportunities, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email, with: ->(email) { email.to_s.downcase.strip }
end
