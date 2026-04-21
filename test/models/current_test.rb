require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  test "session attribute can be set and retrieved" do
    session = sessions(:alice_session)

    Current.session = session

    assert_equal session, Current.session
  end

  test "delegates professional to session" do
    session = sessions(:alice_session)

    Current.session = session

    assert_equal session.professional, Current.professional
  end

  test "professional returns nil when session is nil" do
    Current.session = nil

    assert_nil Current.professional
  end

  test "is isolated per thread" do
    Current.session = sessions(:alice_session)

    Thread.new do
      Current.session = sessions(:bob_session)
      assert_equal professionals(:bob), Current.professional
    end.join

    assert_equal professionals(:alice), Current.professional
  end

  test "clears values after reset" do
    Current.session = sessions(:alice_session)
    assert Current.session.present?

    Current.reset

    assert_nil Current.session
    assert_nil Current.professional
  end
end
