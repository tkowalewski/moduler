module Moduler
  module Administration
    class SessionsController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :session ]) }

      def index
        @filter, @sessions = QueryFilter.new(Session, permitted_filter_parameters).call
      end

      def destroy
      end

      private

      def permitted_filter_parameters
        (params.permit(filter: %i[ query ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
