module Moduler
  class OrganizationsController < ApplicationController
    include OrganizationScoped

    def show; end

    private

    def organization_id_param
      params[:id]
    end
  end
end
