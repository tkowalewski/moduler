require "test_helper"

module Moduler
  module Administration
    class AuditEventsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "index redirects a guest to the sign in page" do
        get "/application/administration/audit_events"

        assert_redirected_to "/application/session/new"
      end

      test "index redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/audit_events"

        assert_redirected_to "/application/"
      end

      test "index lists events with their details, newest first" do
        sign_in_as @administrator

        get "/application/administration/audit_events"

        assert_response :success
        assert_select "#audit_events > li:first-child", text: /session\.signed_in/
        assert_select "##{dom_id(moduler_audit_events(:role_updated))}", text: /admin@domain\.tld.*Role.*10\.0\.0\.1/m
        assert_select "##{dom_id(moduler_audit_events(:role_updated))}", text: /name: Reader → Viewer/
        assert_select "##{dom_id(moduler_audit_events(:role_updated))}", text: /Acme/
      end

      test "index links the audit log in the sidebar" do
        sign_in_as @administrator

        get "/application/administration/audit_events"

        assert_select "aside a[href='/application/administration/audit_events']"
      end

      test "index filters events by query" do
        sign_in_as @administrator

        get "/application/administration/audit_events", params: { filter: { query: "session.signed_in" } }

        assert_select "##{dom_id(moduler_audit_events(:signed_in))}"
        assert_select "##{dom_id(moduler_audit_events(:role_updated))}", count: 0
      end

      test "index filters events by organization" do
        sign_in_as @administrator

        get "/application/administration/audit_events", params: { filter: { organization_id: moduler_organizations(:acme).id } }

        assert_select "#audit_events > li", count: 1
        assert_select "##{dom_id(moduler_audit_events(:role_updated))}"
      end

      private

      def dom_id(record)
        ActionView::RecordIdentifier.dom_id(record)
      end
    end
  end
end
