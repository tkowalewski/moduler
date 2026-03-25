require "test_helper"

module Moduler
  class SessionTest < ActiveSupport::TestCase
    test "responds to user" do
      session = moduler_sessions(:active)
      assert_respond_to session, :user
    end

    test "user returns the associated User record" do
      session = moduler_sessions(:active)
      assert_equal moduler_users(:default), session.user
    end

    test "user association uses Moduler::User as the class" do
      session = moduler_sessions(:active)
      assert_kind_of Moduler::User, session.user
    end

    test "user association uses moduler_user_id as the foreign key" do
      reflection = Moduler::Session.reflect_on_association(:user)
      assert_equal "moduler_user_id", reflection.foreign_key.to_s
    end

    test "user association references the correct class_name" do
      reflection = Moduler::Session.reflect_on_association(:user)
      assert_equal "Moduler::User", reflection.class_name
    end

    test "is invalid without a user" do
      session = Moduler::Session.new(ip_address: "127.0.0.1", signed_in_at: Time.current)
      assert_not session.valid?
      assert session.errors[:user].any?
    end

    test "is valid with a user and no other attributes" do
      session = Moduler::Session.new(user: moduler_users(:default))
      assert session.valid?
    end

    test "is valid with all attributes present" do
      session = Moduler::Session.new(
        user: moduler_users(:default),
        ip_address: "203.0.113.42",
        user_agent: "Mozilla/5.0",
        signed_in_at: Time.current,
        signed_out_at: nil
      )
      assert session.valid?
    end

    test "ip_address is optional" do
      session = Moduler::Session.new(user: moduler_users(:default), ip_address: nil)
      assert session.valid?
    end

    test "user_agent is optional" do
      session = Moduler::Session.new(user: moduler_users(:default), user_agent: nil)
      assert session.valid?
    end

    test "signed_in_at is optional" do
      session = Moduler::Session.new(user: moduler_users(:default), signed_in_at: nil)
      assert session.valid?
    end

    test "signed_out_at is optional" do
      session = Moduler::Session.new(user: moduler_users(:default), signed_out_at: nil)
      assert session.valid?
    end

    test "active fixture has nil signed_out_at" do
      session = moduler_sessions(:active)
      assert_nil session.signed_out_at
    end

    test "active fixture has a non-nil signed_in_at" do
      session = moduler_sessions(:active)
      assert_not_nil session.signed_in_at
    end

    test "active fixture stores ip_address" do
      session = moduler_sessions(:active)
      assert_equal "127.0.0.1", session.ip_address
    end

    test "active fixture stores user_agent" do
      session = moduler_sessions(:active)
      assert_not_nil session.user_agent
    end

    test "signed_out fixture has a non-nil signed_out_at" do
      session = moduler_sessions(:signed_out)
      assert_not_nil session.signed_out_at
    end

    test "signed_out fixture has signed_out_at after signed_in_at" do
      session = moduler_sessions(:signed_out)
      assert session.signed_out_at > session.signed_in_at
    end

    test "id is a UUID string" do
      session = moduler_sessions(:active)
      uuid_format = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
      assert_match uuid_format, session.id.to_s
    end

    test "a new persisted session receives a UUID automatically" do
      session = Moduler::Session.create!(user: moduler_users(:default))
      uuid_format = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
      assert_match uuid_format, session.id.to_s
    end

    test "two sessions created in sequence have different ids" do
      user = moduler_users(:default)
      session_a = Moduler::Session.create!(user: user)
      session_b = Moduler::Session.create!(user: user)
      assert_not_equal session_a.id, session_b.id
    end

    test "can be persisted with only a user" do
      assert_difference "Moduler::Session.count", 1 do
        Moduler::Session.create!(user: moduler_users(:default))
      end
    end

    test "can be persisted with all attributes" do
      assert_difference "Moduler::Session.count", 1 do
        Moduler::Session.create!(
          user: moduler_users(:default),
          ip_address: "10.0.0.1",
          user_agent: "TestAgent/2.0",
          signed_in_at: Time.current
        )
      end
    end

    test "cannot be persisted without a user" do
      assert_no_difference "Moduler::Session.count" do
        Moduler::Session.create(ip_address: "10.0.0.1", signed_in_at: Time.current)
      end
    end

    test "a session with nil signed_out_at is found by the active-session query" do
      active = moduler_sessions(:active)
      found = Moduler::Session.find_by(id: active.id, signed_out_at: nil)
      assert_equal active, found
    end

    test "a session with a signed_out_at timestamp is NOT found by the active-session query" do
      signed_out = moduler_sessions(:signed_out)
      found = Moduler::Session.find_by(id: signed_out.id, signed_out_at: nil)
      assert_nil found
    end

    test "touch(:signed_out_at) sets signed_out_at on an active session" do
      session = moduler_sessions(:active)
      assert_nil session.signed_out_at

      session.touch(:signed_out_at)

      assert_not_nil session.reload.signed_out_at
    end

    test "touch(:signed_out_at) sets signed_out_at to a recent time" do
      session = moduler_sessions(:active)
      freeze_time do
        session.touch(:signed_out_at)
        assert_in_delta Time.current.to_f, session.reload.signed_out_at.to_f, 1.0
      end
    end

    test "after touch(:signed_out_at) the session is no longer found by the active-session query" do
      session = moduler_sessions(:active)
      session.touch(:signed_out_at)

      found = Moduler::Session.find_by(id: session.id, signed_out_at: nil)
      assert_nil found
    end

    test "session is included in its user sessions collection" do
      session = moduler_sessions(:active)
      assert_includes session.user.sessions, session
    end

    test "destroying the user cascades and removes the session" do
      user = Moduler::User.create!(email_address: "cascade@example.com", password: "password123")
      session = user.sessions.create!(ip_address: "1.2.3.4", signed_in_at: Time.current)
      session_id = session.id

      user.destroy

      assert_not Moduler::Session.exists?(session_id)
    end
  end
end
