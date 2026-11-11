module Moduler
  module Administration
    class EmailPolicy < BasePolicy
      def index?
        administrator?
      end

      def create?
        administrator?
      end

      def update?
        administrator?
      end

      def destroy?
        administrator?
      end

      # Sending the email to chosen users.
      def deliver?
        administrator?
      end
    end
  end
end
