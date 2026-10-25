module Moduler
  module Administration
    class TasksController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :tasks ]) }

      def index; end
    end
  end
end
