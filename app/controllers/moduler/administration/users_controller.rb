module Moduler
  module Administration
    class UsersController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :user ]) }
      before_action :set_user, only: %i[ edit update ]

      def index
        @filter, @users = QueryFilter.new(User, permitted_filter_parameters).call
      end

      def new
        @user = User.new
      end

      def create
        @user = User.new(permitted_parameters)

        if @user.save
          redirect_to moduler.administration_users_path, notice: t(".notice")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
      end

      def update
        if @user.update(permitted_update_parameters)
          redirect_to moduler.administration_users_path, notice: t(".notice")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
        authorize(@user, policy_class: UserPolicy)
      end

      def permitted_parameters
        params.expect(user: %i[ email_address role password ])
      end

      def permitted_update_parameters
        params.expect(user: %i[ email_address role ])
      end

      def permitted_filter_parameters
        (params.permit(filter: %i[ query ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
