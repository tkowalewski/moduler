module Moduler
  module Administration
    class TasksPolicy < BasePolicy
      def index?
        administrator?
      end
    end
  end
end
