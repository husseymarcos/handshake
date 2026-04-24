module ToneSelectable
  extend ActiveSupport::Concern

  TONES = %w[Professional Enthusiastic Technical Formal Casual].freeze

  included do
    validates :tone, inclusion: { in: ->(record) { record.class.tones }, allow_blank: true }
  end

  class_methods do
    def tones
      TONES
    end
  end
end
