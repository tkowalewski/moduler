module Moduler
  class ProfileController < ApplicationController
    skip_document_acceptance
    allow_administrator_access

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

    # The current password is required only to change the password.
    def permitted_parameters
      parameters = params.expect(user: %i[ name password_challenge password password_confirmation ])
      parameters[:password].blank? ? parameters.except(:password_challenge, :password, :password_confirmation) : parameters
    end
  end
end
