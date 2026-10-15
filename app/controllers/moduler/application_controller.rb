module Moduler
  class ApplicationController < ActionController::Base
    include Authentication

    default_form_builder FormBuilder

    helper_method :current_user

    private

    def current_user
      Current.user
    end
  end
end
