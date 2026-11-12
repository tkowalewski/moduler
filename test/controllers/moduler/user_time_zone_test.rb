require "test_helper"

module Moduler
  class UserTimeZoneTest < ActionDispatch::IntegrationTest
    setup do
      @user = moduler_users(:default)
      @sent_email = moduler_sent_emails(:default_newsletter)
      @sent_email.update!(created_at: Time.utc(2026, 7, 1, 22, 30))
    end

    test "shows times in the time zone of the signed-in user" do
      @user.update!(time_zone: "Warsaw")
      sign_in_as @user

      get "/application/profile/sent_emails"

      assert_select "time[datetime='2026-07-02T00:30:00+02:00']", text: I18n.l(@sent_email.created_at.in_time_zone("Warsaw"), format: :long)
    end

    test "shows times in the application time zone when the user has none" do
      sign_in_as @user

      get "/application/profile/sent_emails"

      assert_select "time[datetime='#{@sent_email.created_at.in_time_zone(Time.zone_default).xmlschema}']"
    end

    test "restores the application time zone after the request" do
      @user.update!(time_zone: "Warsaw")
      sign_in_as @user

      get "/application/profile/sent_emails"

      assert_equal Time.zone_default, Time.zone
    end
  end
end
