module Moduler
  module Administration
    class AuditEventPolicy < BasePolicy
      def index?
        administrator?
      end

      def show?
        administrator?
      end
    end
  end
end
