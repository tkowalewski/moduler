module Moduler
  module Profile
    class SessionsController < ApplicationController
      def index
        @sessions = Current.user.sessions.order(created_at: :desc).page(params[:page]).per(20)
      end

      def destroy
        session = Current.user.sessions.active.find(params[:id])
        session.touch(:signed_out_at)

        if session == Current.session
          cookies.delete(:session_id)
          redirect_to new_session_path, status: :see_other
        else
          redirect_to profile_sessions_path, status: :see_other
        end
      end

      def revoke
        Current.user.sessions.active.update_all(signed_out_at: Time.current)
        cookies.delete(:session_id)

        redirect_to new_session_path, status: :see_other
      end
    end
  end
end
