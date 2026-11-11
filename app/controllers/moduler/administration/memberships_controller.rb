module Moduler
  module Administration
    class MembershipsController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :membership ]) }
      before_action :set_membership, only: %i[ edit update destroy ]

      def index
        @filter, @memberships = OrganizationQueryFilter.new(Membership.includes(:user, :organization, :role), permitted_filter_parameters).call
      end

      def new
        @membership = Membership.new(moduler_organization_id: params[:organization_id])
      end

      def create
        @membership = Membership.new(permitted_parameters)

        if @membership.save
          redirect_to moduler.administration_memberships_path, notice: t(".notice")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit; end

      def update
        if @membership.update(permitted_update_parameters)
          redirect_to moduler.administration_memberships_path, notice: t(".notice")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @membership.destroy!

        redirect_to moduler.administration_memberships_path, status: :see_other, notice: t(".notice")
      end

      private

      def set_membership
        @membership = Membership.find(params[:id])
        authorize(@membership, policy_class: MembershipPolicy)
      end

      def permitted_parameters
        params.expect(membership: %i[ moduler_organization_id moduler_user_id moduler_role_id ])
      end

      # The organization and user of a membership cannot be changed, only the role.
      def permitted_update_parameters
        params.expect(membership: %i[ moduler_role_id ])
      end

      def permitted_filter_parameters
        (params.permit(filter: %i[ query organization_id ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
