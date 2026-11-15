require "test_helper"

module Moduler
  module Administration
    class AuditEventsHelperTest < ActionView::TestCase
      test "shows lists joined, hashes as JSON and nothing as empty" do
        assert_equal "tasks.read, tasks.write", audit_event_value([ "tasks.read", "tasks.write" ])
        assert_equal JSON.pretty_generate({ "rows" => 3 }), audit_event_value({ "rows" => 3 })
        assert_equal "false", audit_event_value(false)
        [ nil, "", [], {} ].each { |value| assert_equal "(empty)", audit_event_value(value) }
      end

      test "shows the subject by type and short or whole id" do
        event = moduler_audit_events(:role_updated)

        assert_equal "Role #{event.subject_id.first(8)}", audit_event_subject(event)
        assert_equal "Role #{event.subject_id}", audit_event_subject(event, full: true)
        assert_nil audit_event_subject(moduler_audit_events(:signed_in))
      end
    end
  end
end
