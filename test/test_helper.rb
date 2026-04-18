ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module SessionTestHelper
  def sign_in_as(user, password: "secret12")
    post session_url, params: { session: { email: user.email, password: password } }
    assert_redirected_to user_url(user)
    follow_redirect!
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
