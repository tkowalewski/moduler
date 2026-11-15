require "test_helper"

module Moduler
  module Administration
    class AuditEventPolicyTest < ActiveSupport::TestCase
      test "allows only an administrator to list audit events" do
        assert AuditEventPolicy.new(moduler_users(:administrator), AuditEvent).index?
        assert_not AuditEventPolicy.new(moduler_users(:default), AuditEvent).index?
        assert_not AuditEventPolicy.new(nil, AuditEvent).index?
      end
    end
  end
end
