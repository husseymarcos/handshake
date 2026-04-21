class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :professional, to: :session, allow_nil: true
end
