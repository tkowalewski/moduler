module Moduler
  module Administration
    module AuditEventsHelper
      # What an audit event was done to: "Role 6c2a4345" (the whole id with +full: true+).
      def audit_event_subject(event, full: false)
        return unless event.subject_type

        id = event.subject_id.to_s
        "#{event.subject_type.demodulize} #{full ? id : id.first(8)}"
      end

      # A value of the details of an audit event as text: lists joined, hashes as JSON,
      # "(empty)" for nothing.
      def audit_event_value(value)
        return t("moduler.administration.audit_events.show.empty") if value.nil? || value == "" || value == [] || value == {}

        case value
        when Hash then JSON.pretty_generate(value)
        when Array then value.join(", ")
        else value.to_s
        end
      end
    end
  end
end
