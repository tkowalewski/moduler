module Moduler
  module Administration
    class HomeController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :home ]) }

      def index; end
    end
  end
end
