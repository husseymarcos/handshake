class Blueprint
  DEFAULT_PATH = Rails.root.join("config/default.typst")

  class << self
    def body
      @body ||= File.read(DEFAULT_PATH)
    end

    def clear_cache
      remove_instance_variable(:@body) if defined?(@body)
    end
  end
end
