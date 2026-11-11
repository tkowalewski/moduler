module Moduler
  module Administration
    class PreferencesController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :preference ]) }
      before_action :set_preference, only: %i[ edit update destroy ]

      def index
        @filter, @preferences = QueryFilter.new(Preference, permitted_filter_parameters).call
      end

      def new
        @preference = Preference.new
      end

      def create
        @preference = Preference.new(permitted_parameters)

        if @preference.save
          redirect_to moduler.administration_preferences_path, notice: t(".notice")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit; end

      def update
        if @preference.update(permitted_parameters)
          redirect_to moduler.administration_preferences_path, notice: t(".notice")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @preference.destroy!

        redirect_to moduler.administration_preferences_path, status: :see_other, notice: t(".notice")
      end

      private

      def set_preference
        @preference = Preference.find(params[:id])
        authorize(@preference, policy_class: PreferencePolicy)
      end

      def permitted_parameters
        params.expect(preference: %i[ kind name value ])
      end

      def permitted_filter_parameters
        (params.permit(filter: %i[ query ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
