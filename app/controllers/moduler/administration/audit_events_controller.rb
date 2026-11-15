module Moduler
  module Administration
    class AuditEventsController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :audit_event ]) }

      def index
        @filter, @audit_events = OrganizationQueryFilter.new(AuditEvent.includes(:user, :organization), permitted_filter_parameters).call
      end

      private

      def permitted_filter_parameters
        (params.permit(filter: %i[ query organization_id ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
