module Moduler
  # Scopes a controller to the organization in the URL
  # (+/organizations/:organization_id/...+), available as
  # +Current.organization+ and the +current_organization+ helper, and to the
  # signed-in user's membership in it, available as +Current.membership+ and
  # the +current_membership+ helper (its role's permissions are checked with
  # +can?+). The organization is looked up among the signed-in user's organizations; for
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
      Current.membership = Current.user.memberships.includes(:organization, :role).find_by(moduler_organization_id: organization_id_param)
      Current.organization = Current.membership&.organization

      redirect_to moduler.root_path, alert: t("moduler.flash.organization_not_found") unless Current.organization
    end

    def organization_id_param
      params[:organization_id]
    end
  end
end
