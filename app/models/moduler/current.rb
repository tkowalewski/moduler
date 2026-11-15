module Moduler
  class Current < ActiveSupport::CurrentAttributes
    attribute :session, :organization, :membership
    # Of the request, for audit events (set by Moduler::ApplicationController).
    attribute :ip_address, :request_id
    delegate :user, to: :session, allow_nil: true
  end
end
