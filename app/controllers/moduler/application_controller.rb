module Moduler
  class ApplicationController < ActionController::Base
    include Authentication
    include RestrictAdministratorAccess
    include RequireDocumentAcceptance
    include Pundit::Authorization

    default_form_builder FormBuilder

    rescue_from Pundit::NotAuthorizedError, with: :not_authorized

    helper_method :current_user, :current_organization

    private

    def current_user
      Current.user
    end

    def current_organization
      Current.organization
    end

    def not_authorized
      redirect_to current_home_path, alert: t("moduler.flash.not_authorized")
    end
  end
end
