module Moduler
  # Scopes a controller to the organization in the URL
  # (+/organizations/:organization_id/...+), available as
  # +Current.organization+ and the +current_organization+ helper. The
  # organization is looked up among the signed-in user's organizations; for
  # any other organization (for example after the user was removed from it)
  # the user is redirected to the home page to choose another one. Keeping the
  # organization in the URL lets every browser tab work in a different
  # organization.
  module OrganizationScoped
    extend ActiveSupport::Concern

    included do
      before_action :set_current_organization
    end

    private

    def set_current_organization
      Current.organization = Current.user.organizations.find_by(id: organization_id_param)

      redirect_to moduler.root_path, alert: t("moduler.flash.organization_not_found") unless Current.organization
    end

    def organization_id_param
      params[:organization_id]
    end
  end
end
