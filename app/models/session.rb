class Session < ApplicationRecord
  belongs_to :professional

  attr_reader :plain_token

  before_validation :assign_token, on: :create

  def self.digest(token)
    Digest::SHA256.hexdigest(token)
  end

  private

    def assign_token
      @plain_token = SecureRandom.urlsafe_base64(32)
      self.token_digest = self.class.digest(@plain_token)
    end
end
