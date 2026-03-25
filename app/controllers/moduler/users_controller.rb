module Moduler
  class UsersController < ApplicationController
    allow_unauthenticated_access only: %i[ new create ]

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
