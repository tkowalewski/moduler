module Moduler
  class SessionsController < ApplicationController
    allow_unauthenticated_access only: %i[ new create ]

    rate_limit to: 10, within: 3.minutes, only: :create,
      with: -> { redirect_to moduler.new_session_path, alert: t("moduler.sessions.create.rate_limited") }

    rate_limit to: 5, within: 3.minutes, only: :create,
      by: -> { params.dig(:user, :email_address) },
      with: -> { redirect_to moduler.new_session_path, alert: t("moduler.sessions.create.rate_limited") }

    def new
      if authenticated?
        redirect_to after_authentication_url
      end

      @user = User.new
    end

    def create
      user = User.authenticate_by(params.require(:user).permit(:email_address, :password))

      if user&.active?
        start_new_session_for user

        redirect_to after_authentication_url
      else
        render_sign_in_error(user ? "inactive_account" : "invalid_credentials")
      end
    end

    def destroy
      terminate_session
      redirect_to moduler.new_session_path, status: :see_other
    end

    private

    def render_sign_in_error(key)
      @user = User.new.tap do |user|
        user.errors.add(:base, t("moduler.sessions.create.#{key}"))
      end

      render :new
    end
  end
end
