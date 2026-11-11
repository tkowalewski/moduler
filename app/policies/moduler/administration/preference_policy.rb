module Moduler
  module Administration
    class PreferencePolicy < BasePolicy
      def index?
        administrator?
      end

      def create?
        administrator?
      end

      def update?
        administrator?
      end

      def new?
        create?
      end

      def edit?
        update?
      end

      def destroy?
        administrator?
      end
    end
  end
end
