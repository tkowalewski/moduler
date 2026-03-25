module Moduler
  class ApplicationController < ActionController::Base
    include Authentication

    default_form_builder FormBuilder
  end
end
