module Moduler
  module Administration
    module AuditEventsHelper
      # The details of an audit event in one line: "role: Viewer → Owner, reason: invalid_credentials".
      def audit_event_details(event)
        changes = event.metadata.fetch("changes", {}).map { |attribute, (from, to)| "#{attribute}: #{audit_value(from)} → #{audit_value(to)}" }
        details = event.metadata.except("changes").map { |key, value| "#{key}: #{audit_value(value)}" }
        (changes + details).join(", ")
      end

      private

      def audit_value(value)
        value.nil? || value == "" ? "–" : Array(value).join(", ")
      end
    end
  end
end
