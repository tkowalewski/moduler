module Moduler
  module Administration
    class HomePolicy < BasePolicy
      def index?
        administrator?
      end
    end
  end
end
