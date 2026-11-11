module Moduler
  module Administration
    class ApplicationController < ::Moduler::ApplicationController
      after_action :verify_authorized

      skip_document_acceptance if: -> { current_user&.administrator? }
      allow_administrator_access
    end
  end
end
