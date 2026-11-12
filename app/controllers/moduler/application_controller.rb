module Moduler
  class ApplicationController < ActionController::Base
    include Authentication
    include RestrictAdministratorAccess
    include RequireDocumentAcceptance
    include UserTimeZone
    include Pundit::Authorization

    default_form_builder FormBuilder

    rescue_from Pundit::NotAuthorizedError, with: :not_authorized

    helper_method :current_user, :current_organization, :current_membership, :can?

    private

    def current_user
      Current.user
    end

    def current_organization
      Current.organization
    end

    def current_membership
      Current.membership
    end

    # Whether the signed-in user's role in the current organization grants the
    # permission (one of `permissions` in config/moduler.yml). Always false
    # outside an organization (see OrganizationScoped).
    def can?(permission)
      current_membership&.permission?(permission) || false
    end

    def not_authorized
      redirect_to current_home_path, alert: t("moduler.flash.not_authorized")
    end
  end
end
