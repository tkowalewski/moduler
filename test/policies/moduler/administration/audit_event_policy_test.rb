require "test_helper"

module Moduler
  module Administration
    class AuditEventPolicyTest < ActiveSupport::TestCase
      test "allows only an administrator to see audit events" do
        assert AuditEventPolicy.new(moduler_users(:administrator), AuditEvent).index?
        assert AuditEventPolicy.new(moduler_users(:administrator), AuditEvent).show?

        [ moduler_users(:default), nil ].each do |user|
          assert_not AuditEventPolicy.new(user, AuditEvent).index?
          assert_not AuditEventPolicy.new(user, AuditEvent).show?
        end
      end
    end
  end
end
