module Moduler
  class ProfileController < ApplicationController
    def edit
      @user = Current.user
    end

    def update
      @user = Current.user

      @user.assign_attributes(permitted_parameters)

      if @user.save(context: :self_service_update)
        @user.sessions.active.where.not(id: Current.session.id).update_all(signed_out_at: Time.current) if @user.saved_change_to_password_digest?

        redirect_to moduler.edit_profile_path, notice: t(".notice")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def permitted_parameters
      params.expect(user: %i[ password_challenge password password_confirmation ])
    end
  end
end
