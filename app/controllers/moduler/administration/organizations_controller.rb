module Moduler
  module Administration
    class OrganizationsController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :organization ]) }
      before_action :set_organization, only: %i[ edit update ]

      def index
        @filter, @organizations = QueryFilter.new(Organization.all, permitted_filter_parameters).call
      end

      def new
        @organization = Organization.new
      end

      def create
        @organization = Organization.new(permitted_parameters)

        if @organization.save
          redirect_to moduler.administration_organizations_path, notice: t(".notice")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit; end

      def update
        if @organization.update(permitted_parameters)
          redirect_to moduler.administration_organizations_path, notice: t(".notice")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def set_organization
        @organization = Organization.find(params[:id])
        authorize(@organization, policy_class: OrganizationPolicy)
      end

      def permitted_parameters
        params.expect(organization: %i[ name ])
      end

      def permitted_filter_parameters
        (params.permit(filter: %i[ query ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
