module Moduler
  module Administration
    class RolesController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :role ]) }
      before_action :set_role, only: %i[ edit update ]

      def index
        @filter, @roles = OrganizationQueryFilter.new(Role.includes(:organization), permitted_filter_parameters).call
      end

      def new
        @role = Role.new(moduler_organization_id: params[:organization_id])
      end

      def create
        @role = Role.new(permitted_parameters)

        if @role.save
          redirect_to moduler.administration_roles_path, notice: t(".notice")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit; end

      def update
        if @role.update(permitted_update_parameters)
          redirect_to moduler.administration_roles_path, notice: t(".notice")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def set_role
        @role = Role.find(params[:id])
        authorize(@role, policy_class: RolePolicy)
      end

      def permitted_parameters
        params.expect(role: [ :moduler_organization_id, :name, permissions: [] ])
      end

      # The organization is set only when the role is created and cannot be changed.
      def permitted_update_parameters
        params.expect(role: [ :name, permissions: [] ])
      end

      def permitted_filter_parameters
        (params.permit(filter: %i[ query organization_id ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
