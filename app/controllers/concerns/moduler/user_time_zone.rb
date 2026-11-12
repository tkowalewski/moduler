module Moduler
  # Runs each request in the time zone chosen by the signed-in user in their
  # profile, or in the application's time zone (config.time_zone) for users
  # without one and for visitors who are not signed in.
  module UserTimeZone
    extend ActiveSupport::Concern

    included do
      around_action :use_user_time_zone
    end

    private

    def use_user_time_zone(&)
      Time.use_zone(Current.user&.time_zone.presence || Time.zone_default, &)
    end
  end
end
