require "test_helper"

module Moduler
  class AuditEventTest < ActiveSupport::TestCase
    test "requires an action" do
      event = AuditEvent.new

      assert_not event.valid?
      assert event.errors.of_kind?(:action, :blank)
    end

    test "is valid without a user, an organization or a subject" do
      assert AuditEvent.new(action: "session.sign_in_failed").valid?
    end

    test "cannot be changed or removed once recorded" do
      event = moduler_audit_events(:role_updated)

      assert_raises(ActiveRecord::ReadOnlyRecord) { event.update!(action: "role.created") }
      assert_raises(ActiveRecord::ReadOnlyRecord) { event.destroy! }
    end

    test "outlives the user it was recorded for" do
      event = moduler_audit_events(:signed_in)

      moduler_users(:default).destroy!

      assert_nil event.reload.user
    end

    test "belongs to its subject" do
      assert_equal moduler_roles(:acme_viewer), moduler_audit_events(:role_updated).subject
    end

    test "searches by action, email address and IP address" do
      assert_includes AuditEvent.search_by_query("role.updated"), moduler_audit_events(:role_updated)
      assert_includes AuditEvent.search_by_query("test@domain.tld"), moduler_audit_events(:signed_in)
      assert_includes AuditEvent.search_by_query("10.0.0.1"), moduler_audit_events(:role_updated)
    end
  end
end
