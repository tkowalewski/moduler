module Moduler
  module Administration
    class SessionPolicy < BasePolicy
      def index?
        administrator?
      end

      def destroy?
        administrator?
      end
    end
  end
end
