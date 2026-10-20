module Moduler
  module Administration
    class UsersController < ApplicationController
      def index
        @filter, @users = QueryFilter.new(User, permitted_filter_parameters).call
      end

      def new
      end

      def create
      end

      def edit
      end

      def update
      end

      private

      def permitted_filter_parameters
        (params.permit(filter: %i[ query ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
