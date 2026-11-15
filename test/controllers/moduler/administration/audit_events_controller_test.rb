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

      test "index lists events newest first, with a link to their details instead of the changes" do
        event = moduler_audit_events(:role_updated)
        sign_in_as @administrator

        get "/application/administration/audit_events"

        assert_response :success
        assert_select "#audit_events > li:first-child", text: /session\.signed_in/
        assert_select "##{dom_id(event)}", text: /admin@domain\.tld.*Role.*10\.0\.0\.1/m
        assert_select "##{dom_id(event)}", text: /Acme/
        assert_select "##{dom_id(event)}", text: /Reader/, count: 0
        assert_select "##{dom_id(event)} a[href='/application/administration/audit_events/#{event.id}']", text: "Details"
      end

      test "show redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/audit_events/#{moduler_audit_events(:role_updated).id}"

        assert_redirected_to "/application/"
      end

      test "show renders the event with its changes before and after" do
        event = moduler_audit_events(:role_updated)
        sign_in_as @administrator

        get "/application/administration/audit_events/#{event.id}"

        assert_response :success
        assert_select "h1", text: "role.updated"
        assert_select "#event", text: /admin@domain\.tld/
        assert_select "#event", text: /Acme/
        assert_select "#event", text: /Role #{event.subject_id}/
        assert_select "#event", text: /10\.0\.0\.1/
        assert_select "#changes > div", count: 2
        assert_select "#changes > div:first-child" do
          assert_select "dt", text: "name"
          assert_select "dd > div:first-child", text: /Before\s+Reader/
          assert_select "dd > div:last-child", text: /After\s+Viewer/
        end
        assert_select "#changes > div:last-child dd > div:first-child", text: /Before\s+tasks\.read\z/
        assert_select "#changes > div:last-child dd > div:last-child", text: /After\s+tasks\.read, tasks\.write/
        assert_select "#details", count: 0
      end

      test "show renders the details of an event without changes" do
        sign_in_as @administrator

        get "/application/administration/audit_events/#{moduler_audit_events(:sign_in_failed).id}"

        assert_select "#changes", count: 0
        assert_select "#details", text: /reason.*invalid_credentials/m
        assert_select "#event", text: /Unknown/
      end

      test "show responds with not found for an unknown event" do
        sign_in_as @administrator

        get "/application/administration/audit_events/00000000-0000-0000-0000-000000000000"

        assert_response :not_found
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
