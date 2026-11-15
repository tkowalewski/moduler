module Moduler
  # Records audit events (see Moduler::AuditEvent):
  #
  #   Moduler::Audit.record("role.updated", role, changes: role.saved_changes)
  #   Moduler::Audit.record("report.exported", report, format: "csv")
  #
  # The action names what was done (+<subject>.<past tense>+), the subject is the record it
  # was done to, and other keywords are kept as details. +changes+ (e.g. +saved_changes+)
  # are kept without timestamps and password digests. The user, the IP address and the
  # request come from Moduler::Current; the organization too, or else from the subject.
  module Audit
    IGNORED_CHANGES = %w[ created_at updated_at password_digest ].freeze

    def self.record(action, subject = nil, user: Current.user, organization: nil, changes: nil, **details)
      details[:changes] = changes.except(*IGNORED_CHANGES) if changes.present?

      AuditEvent.create!(action:, subject:, user:, organization: organization || organization_of(subject), metadata: details,
        ip_address: Current.ip_address, request_id: Current.request_id)
    end

    def self.organization_of(subject)
      return Current.organization if Current.organization
      return subject if subject.is_a?(Organization)

      subject.organization if subject.respond_to?(:organization) && subject.organization.is_a?(Organization)
    end
    private_class_method :organization_of
  end
end
