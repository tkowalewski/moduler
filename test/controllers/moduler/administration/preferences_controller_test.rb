require "test_helper"

module Moduler
  module Administration
    class PreferencesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
        @preference = moduler_preferences(:waitlist)
      end

      test "index redirects a guest to the sign in page" do
        get "/application/administration/preferences"

        assert_redirected_to "/application/session/new"
      end

      test "index redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/preferences"

        assert_redirected_to "/application/"
      end

      test "index lists preferences for an administrator" do
        sign_in_as @administrator

        get "/application/administration/preferences"

        assert_response :success
        assert_select "#preferences > li", count: Moduler::Preference.count
        assert_select "##{dom_id(@preference)}" do
          assert_select "p", text: "WAITLIST"
          assert_select "span", text: "Boolean"
          assert_select "span.font-mono", text: "true"
          assert_select "a[href='/application/administration/preferences/#{@preference.id}/edit']"
          assert_select "form[action='/application/administration/preferences/#{@preference.id}'] input[name='_method'][value='delete']"
        end
        assert_select "a[href='/application/administration/preferences/new']"
      end

      test "index links the preferences page in the sidebar" do
        sign_in_as @administrator

        get "/application/administration/preferences"

        assert_select "aside a.bg-slate-100[href='/application/administration/preferences']", text: "Preferences"
      end

      test "index filters preferences by query" do
        sign_in_as @administrator

        get "/application/administration/preferences", params: { filter: { query: "WAITLIST" } }

        assert_response :success
        assert_select "#preferences > li", count: 1
        assert_select "##{dom_id(@preference)}"
      end

      test "index renders an empty state when no preferences match the query" do
        sign_in_as @administrator

        get "/application/administration/preferences", params: { filter: { query: "zzzzzz" } }

        assert_response :success
        assert_select "#preferences", count: 0
        assert_match "No preferences found", response.body
      end

      test "new renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/preferences/new"

        assert_response :success
        assert_select "form[action='/application/administration/preferences']" do
          assert_select "input[name='preference[name]'][placeholder='WAITLIST']"
          assert_select "select[name='preference[kind]'] option[value]", count: Moduler::Preference::KINDS.size + 1
          assert_select "select[name='preference[kind]'] option[value='integer']", text: "Integer"
          assert_select "input[name='preference[value]']"
        end
      end

      test "new redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/preferences/new"

        assert_redirected_to "/application/"
      end

      test "create creates a preference and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { Moduler::Preference.count }, 1 do
          post "/application/administration/preferences", params: { preference: { kind: "boolean", name: "REGISTRATION", value: " False " } }
        end

        assert_redirected_to "/application/administration/preferences"
        assert_equal "Preference has been created", flash[:notice]
        assert_equal "false", Moduler::Preference.find_by!(name: "REGISTRATION").value
        assert_equal false, Moduler::Preference::REGISTRATION
      end

      test "create re-renders the form when the name is already taken" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Preference.count } do
          post "/application/administration/preferences", params: { preference: { kind: "boolean", name: "WAITLIST", value: "false" } }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/preferences']"
        assert_match "has already been taken", response.body
      end

      test "create re-renders the form when the value does not match the kind" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Preference.count } do
          post "/application/administration/preferences", params: { preference: { kind: "integer", name: "LIMIT", value: "many" } }
        end

        assert_response :unprocessable_entity
      end

      test "create responds with bad request when preference params are missing" do
        sign_in_as @administrator

        post "/application/administration/preferences"

        assert_response :bad_request
      end

      test "create redirects a member to the home page" do
        sign_in_as @member

        assert_no_difference -> { Moduler::Preference.count } do
          post "/application/administration/preferences", params: { preference: { kind: "boolean", name: "REGISTRATION", value: "true" } }
        end

        assert_redirected_to "/application/"
      end

      test "edit renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/preferences/#{@preference.id}/edit"

        assert_response :success
        assert_select "form[action='/application/administration/preferences/#{@preference.id}']" do
          assert_select "input[name='_method'][value='patch']"
          assert_select "input[name='preference[name]'][value='WAITLIST']"
          assert_select "select[name='preference[kind]'] option[selected][value='boolean']"
          assert_select "input[name='preference[value]'][value='true']"
        end
      end

      test "edit responds with not found for an unknown preference" do
        sign_in_as @administrator

        get "/application/administration/preferences/#{SecureRandom.uuid}/edit"

        assert_response :not_found
      end

      test "edit redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/preferences/#{@preference.id}/edit"

        assert_redirected_to "/application/"
      end

      test "update changes the value and redirects to the list" do
        sign_in_as @administrator

        patch "/application/administration/preferences/#{@preference.id}", params: { preference: { value: "false" } }

        assert_redirected_to "/application/administration/preferences"
        assert_equal "Preference has been updated", flash[:notice]
        assert_equal false, Moduler::Preference::WAITLIST
      end

      test "update re-renders the form when the preference is invalid" do
        sign_in_as @administrator

        assert_no_changes -> { @preference.reload.value } do
          patch "/application/administration/preferences/#{@preference.id}", params: { preference: { value: "yes" } }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/preferences/#{@preference.id}']"
      end

      test "update redirects a member to the home page" do
        sign_in_as @member

        assert_no_changes -> { @preference.reload.value } do
          patch "/application/administration/preferences/#{@preference.id}", params: { preference: { value: "false" } }
        end

        assert_redirected_to "/application/"
      end

      test "destroy deletes the preference and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { Moduler::Preference.count }, -1 do
          delete "/application/administration/preferences/#{@preference.id}"
        end

        assert_redirected_to "/application/administration/preferences"
        assert_equal "Preference has been deleted", flash[:notice]
        assert_nil Moduler::Preference::WAITLIST
      end

      test "destroy responds with not found for an unknown preference" do
        sign_in_as @administrator

        delete "/application/administration/preferences/#{SecureRandom.uuid}"

        assert_response :not_found
      end

      test "destroy redirects a member to the home page" do
        sign_in_as @member

        assert_no_difference -> { Moduler::Preference.count } do
          delete "/application/administration/preferences/#{@preference.id}"
        end

        assert_redirected_to "/application/"
      end
    end
  end
end
