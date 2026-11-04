module Moduler
  module Administration
    class DocumentPolicy < BasePolicy
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
    end
  end
end
