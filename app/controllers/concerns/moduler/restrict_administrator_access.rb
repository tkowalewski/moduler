module Moduler
  # Keeps administrators out of the application: they are redirected to the
  # administration area. Controllers administrators may use (the
  # administration area, the profile, signing in and out, public pages) opt
  # out with +allow_administrator_access+.
  module RestrictAdministratorAccess
    extend ActiveSupport::Concern

    included do
      before_action :restrict_administrator_access
      helper_method :current_home_path
    end

    class_methods do
      def allow_administrator_access(**options)
        skip_before_action :restrict_administrator_access, **options
      end
    end

    private

    # The home page of the signed-in user: the administration area for
    # administrators, the application for everyone else.
    def current_home_path
      Current.user&.administrator? ? moduler.administration_root_path : moduler.root_path
    end

    def restrict_administrator_access
      redirect_to moduler.administration_root_path if Current.user&.administrator?
    end
  end
end
