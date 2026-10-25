module Moduler
  module Administration
    class SessionsController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :session ]) }
      before_action :set_session, only: %i[ destroy ]

      def index
        @filter, @sessions = QueryFilter.new(Session.includes(:user), permitted_filter_parameters).call
      end

      def destroy
        @session.touch(:signed_out_at)

        if @session == Current.session
          cookies.delete(:session_id)
          redirect_to moduler.new_session_path, status: :see_other
        else
          redirect_to moduler.administration_sessions_path, status: :see_other, notice: t(".notice")
        end
      end

      private

      def set_session
        @session = Session.active.find(params[:id])
        authorize(@session, policy_class: SessionPolicy)
      end

      def permitted_filter_parameters
        (params.permit(filter: %i[ query ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
