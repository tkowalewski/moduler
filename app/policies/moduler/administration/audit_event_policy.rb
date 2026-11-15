module Moduler
  module Administration
    class AuditEventPolicy < BasePolicy
      def index?
        administrator?
      end
    end
  end
end
