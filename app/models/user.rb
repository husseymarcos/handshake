class User < ApplicationRecord
  include Skillable

  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :opportunities, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email, with: ->(email) { email.to_s.downcase.strip }
end
