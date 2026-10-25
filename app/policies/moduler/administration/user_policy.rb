module Moduler
  module Administration
    class UserPolicy < BasePolicy
      def index?
        administrator?
      end

      def create?
        administrator?
      end

      def update?
        administrator? && record != user
      end

      def new?
        create?
      end

      def edit?
        update?
      end
    end
  end
end
