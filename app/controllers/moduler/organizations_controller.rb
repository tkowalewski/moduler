module Moduler
  # Entry point of an organization, linked from the home page and the
  # organization switcher. It has no page of its own: members are sent to the
  # first sidebar resource from config/moduler.yml they may see, or back to
  # the home page when their role grants none.
  class OrganizationsController < ApplicationController
    include OrganizationScoped

    def show
      if (resource = current_membership.home_resource)
        redirect_to moduler.polymorphic_path([ current_organization, resource.name.to_sym ])
      else
        redirect_to moduler.root_path, alert: t(".no_resources")
      end
    end

    private

    def organization_id_param
      params[:id]
    end
  end
end
