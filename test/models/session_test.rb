require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "generates token digest on creation" do
    session = professionals(:alice).sessions.create!

    assert session.token_digest.present?
    assert session.plain_token.present?
  end

  test "plain token is different from digest" do
    session = professionals(:alice).sessions.create!

    assert_not_equal session.plain_token, session.token_digest
  end

  test "digest is consistent for same token" do
    token = "test_token_123"
    digest1 = Session.digest(token)
    digest2 = Session.digest(token)

    assert_equal digest1, digest2
  end

  test "different tokens produce different digests" do
    digest1 = Session.digest("token1")
    digest2 = Session.digest("token2")

    assert_not_equal digest1, digest2
  end

  test "belongs to professional" do
    session = sessions(:alice_session)

    assert_equal professionals(:alice), session.professional
  end

  test "sessions are destroyed when professional is destroyed" do
    professional = Professional.create!(name: "Temp User", email: "temp@example.com", password: "secret12")
    session = professional.sessions.create!

    assert_difference("Session.count", -1) do
      professional.destroy
    end

    assert_not Session.exists?(session.id)
  end

  test "each session has unique token" do
    session1 = professionals(:alice).sessions.create!
    session2 = professionals(:alice).sessions.create!

    assert_not_equal session1.plain_token, session2.plain_token
    assert_not_equal session1.token_digest, session2.token_digest
  end
end
