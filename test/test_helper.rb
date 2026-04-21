ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Dir[Rails.root.join("test/test_helpers/**/*.rb")].each { |f| require f }

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    include ResumeGenerationTestHelper, SessionTestHelper
  end
end
