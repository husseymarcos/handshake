require "test_helper"

class ProfessionalTest < ActiveSupport::TestCase
  test "a professional can add capabilities to their portfolio" do
    professionals(:alice).capabilities.destroy_all
    professionals(:alice).add_capability("TypeScript")
    assert_equal [ "TypeScript" ], professionals(:alice).capabilities.alphabetically.pluck(:name)
  end

  test "a professional can only manage their own portfolio assets" do
    capability = professionals(:bob).capabilities.create!(name: "Python")
    assert_not professionals(:alice).owns?(capability)
    assert professionals(:alice).owns?(professionals(:alice).capabilities.first)
  end

  test "name is required" do
    professional = Professional.new(email: "test@example.com", password: "secret12")
    assert_not professional.valid?
    assert_includes professional.errors[:name], "can't be blank"
  end

  test "email is required" do
    professional = Professional.new(name: "Test User", password: "secret12")
    assert_not professional.valid?
    assert_includes professional.errors[:email], "can't be blank"
  end

  test "email must be unique" do
    professional = Professional.new(name: "Test User", email: professionals(:alice).email, password: "secret12")
    assert_not professional.valid?
    assert_includes professional.errors[:email], "has already been taken"
  end

  test "email uniqueness is case insensitive" do
    professional = Professional.new(name: "Test User", email: professionals(:alice).email.upcase, password: "secret12")
    assert_not professional.valid?
    assert_includes professional.errors[:email], "has already been taken"
  end

  test "email must be valid format" do
    invalid_emails = [ "not-an-email", "@example.com", "test@", "test@.com" ]

    invalid_emails.each do |email|
      professional = Professional.new(name: "Test User", email: email, password: "secret12")
      assert_not professional.valid?, "Expected #{email} to be invalid"
      assert_includes professional.errors[:email], "is invalid"
    end
  end

  test "valid email formats are accepted" do
    valid_emails = [ "test@example.com", "user+tag@example.co.uk", "first.last@example.com", "user123@test.io" ]

    valid_emails.each do |email|
      professional = Professional.new(name: "Test User", email: email, password: "secret12")
      professional.valid?
      assert_not_includes professional.errors[:email], "is invalid", "Expected #{email} to be valid"
    end
  end

  test "email is normalized to lowercase" do
    professional = Professional.create!(name: "Upper Case", email: "UPPERCASE@EXAMPLE.COM", password: "secret12")
    assert_equal "uppercase@example.com", professional.reload.email
  end

  test "email is stripped of whitespace" do
    professional = Professional.create!(name: "Test User", email: "  test@example.com  ", password: "secret12")
    assert_equal "test@example.com", professional.email
  end

  test "password is required" do
    professional = Professional.new(name: "Test User", email: "test@example.com")
    assert_not professional.valid?
  end

  test "has_secure_password verifies authentication" do
    assert professionals(:alice).authenticate("secret12")
    assert_not professionals(:alice).authenticate("wrongpassword")
  end

  test "destroying professional destroys dependent sessions" do
    professionals(:alice).sessions.create!

    assert_difference("Session.count", -professionals(:alice).sessions.count) do
      professionals(:alice).destroy
    end
  end

  test "destroying professional destroys dependent experiences" do
    assert professionals(:alice).experiences.any?

    assert_difference("Experience.count", -professionals(:alice).experiences.count) do
      professionals(:alice).destroy
    end
  end

  test "destroying professional destroys dependent capabilities" do
    assert professionals(:alice).capabilities.any?

    assert_difference("Capability.count", -professionals(:alice).capabilities.count) do
      professionals(:alice).destroy
    end
  end

  test "destroying professional destroys dependent opportunities" do
    assert professionals(:alice).opportunities.any?

    assert_difference("Opportunity.count", -professionals(:alice).opportunities.count) do
      professionals(:alice).destroy
    end
  end

  test "owns? returns false for non-professional resources" do
    class NonProfessionalResource
      def professional_id
        nil
      end
    end

    assert_not professionals(:alice).owns?(NonProfessionalResource.new)
  end

  test "owns? returns false for resource without professional_id method" do
    class NoProfessionalId
    end

    assert_not professionals(:alice).owns?(NoProfessionalId.new)
  end

  test "add_capability strips whitespace from name" do
    professionals(:alice).capabilities.destroy_all
    professionals(:alice).add_capability("  Ruby  ")
    assert_equal "Ruby", professionals(:alice).capabilities.first.name
  end

  test "remove_capability does nothing if capability is not owned" do
    bob_capability = professionals(:bob).capabilities.first

    assert_no_difference("Capability.count") do
      professionals(:alice).remove_capability(bob_capability)
    end
  end
end
