module Moduler
  module Administration
    class BasePolicy < ApplicationPolicy
      private

      def administrator?
        user&.administrator?
      end
    end
  end
end
