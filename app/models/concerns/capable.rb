module Capable
  extend ActiveSupport::Concern

  included do
    has_many :capabilities, dependent: :destroy
  end

  def add_capability(name)
    capabilities.create!(name: name.to_s.strip)
  end

  def remove_capability(capability)
    capability.destroy! if owns?(capability)
  end

  def owns?(resource)
    resource.respond_to?(:professional_id) && resource.professional_id == id
  end
end
