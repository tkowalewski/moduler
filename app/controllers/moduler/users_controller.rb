module Moduler
  class UsersController < ApplicationController
    allow_unauthenticated_access only: %i[ new create ]

    rate_limit to: 10, within: 3.minutes, only: :create,
      with: -> { redirect_to moduler.new_user_path, alert: t("moduler.users.create.rate_limited") }

    rate_limit to: 5, within: 3.minutes, only: :create,
      by: -> { params.dig(:user, :email_address) },
      with: -> { redirect_to moduler.new_user_path, alert: t("moduler.users.create.rate_limited") }

    def new
      if authenticated?
        redirect_to after_authentication_url
      end

      @user = User.new
    end

    def create
      @user = User.new(permitted_parameters)

      if @user.save
        redirect_to moduler.new_session_path, notice: t("moduler.users.create.success")
      else
        render :new
      end
    end

    private

    def permitted_parameters
      params.require(:user).permit(:email_address, :password, :password_confirmation)
    end
  end
end
