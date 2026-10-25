module Moduler
  module Administration
    class ApplicationController < ::Moduler::ApplicationController
      after_action :verify_authorized
    end
  end
end
