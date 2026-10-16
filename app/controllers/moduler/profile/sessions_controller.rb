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
          redirect_to moduler.new_session_path, status: :see_other
        else
          redirect_to moduler.profile_sessions_path, status: :see_other
        end
      end
    end
  end
end
