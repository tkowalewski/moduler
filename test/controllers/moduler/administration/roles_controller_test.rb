require "test_helper"

module Moduler
  module Administration
    class RolesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
        @organization = moduler_organizations(:acme)
        @role = moduler_roles(:acme_owner)
      end

      test "index redirects a guest to the sign in page" do
        get "/application/administration/roles"

        assert_redirected_to "/application/session/new"
      end

      test "index redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/roles"

        assert_redirected_to "/application/"
      end

      test "index lists roles of all organizations for an administrator" do
        sign_in_as @administrator

        get "/application/administration/roles"

        assert_response :success
        assert_select "#roles > li", count: Moduler::Role.count
        assert_select "##{dom_id(@role)}" do
          assert_select "p", text: "Owner"
          assert_select "span", text: "Acme"
          assert_match "3 permissions", response.body
          assert_select "a[href='/application/administration/roles/#{@role.id}/edit']"
        end
        assert_select "a[href='/application/administration/roles/new']"
      end

      test "index links the roles page in the sidebar" do
        sign_in_as @administrator

        get "/application/administration/roles"

        assert_select "aside a.bg-slate-100[href='/application/administration/roles']", text: "Roles"
      end

      test "index renders the organization filter" do
        sign_in_as @administrator

        get "/application/administration/roles"

        assert_select "select[name='filter[organization_id]']" do
          assert_select "option[value='']", text: "All organizations"
          assert_select "option[value='#{@organization.id}']", text: "Acme"
        end
      end

      test "index filters roles by organization" do
        sign_in_as @administrator

        get "/application/administration/roles", params: { filter: { organization_id: @organization.id } }

        assert_response :success
        assert_select "#roles > li", count: @organization.roles.count
        assert_select "##{dom_id(moduler_roles(:globex_owner))}", count: 0
        assert_select "select[name='filter[organization_id]'] option[selected][value='#{@organization.id}']"
        assert_select "a[href='/application/administration/roles/new?organization_id=#{@organization.id}']"
      end

      test "index filters roles by query" do
        sign_in_as @administrator

        get "/application/administration/roles", params: { filter: { query: "Viewer" } }

        assert_response :success
        assert_select "#roles > li", count: 1
        assert_select "#roles", text: /Viewer/
      end

      test "index renders an empty state when no roles match the query" do
        sign_in_as @administrator

        get "/application/administration/roles", params: { filter: { query: "zzzzzz" } }

        assert_response :success
        assert_select "#roles", count: 0
        assert_match "No roles found", response.body
      end

      test "new renders the form with organizations and configured permissions for an administrator" do
        sign_in_as @administrator

        get "/application/administration/roles/new"

        assert_response :success
        assert_select "form[action='/application/administration/roles']" do
          assert_select "select[name='role[moduler_organization_id]'] option[value='#{@organization.id}']", text: "Acme"
          assert_select "select[name='role[moduler_organization_id]'] option[selected]", count: 0
          assert_select "input[name='role[name]']"
          assert_select "input[type='checkbox'][name='role[permissions][]']", count: Moduler.configuration.permissions.size
        end
      end

      test "new preselects the organization from params" do
        sign_in_as @administrator

        get "/application/administration/roles/new", params: { organization_id: @organization.id }

        assert_select "select[name='role[moduler_organization_id]'] option[selected][value='#{@organization.id}']"
      end

      test "new redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/roles/new"

        assert_redirected_to "/application/"
      end

      test "create creates a role in the organization and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { @organization.roles.count }, 1 do
          post "/application/administration/roles", params: {
            role: { moduler_organization_id: @organization.id, name: "Editor", permissions: [ "", "tasks.read", "tasks.write" ] }
          }
        end

        assert_redirected_to "/application/administration/roles"
        assert_equal "Role has been created", flash[:notice]
        assert_equal %w[ tasks.read tasks.write ], @organization.roles.find_by!(name: "Editor").permissions
      end

      test "create creates a role without permissions" do
        sign_in_as @administrator

        post "/application/administration/roles", params: { role: { moduler_organization_id: @organization.id, name: "Guest", permissions: [ "" ] } }

        assert_redirected_to "/application/administration/roles"
        assert_equal [], @organization.roles.find_by!(name: "Guest").permissions
      end

      test "create re-renders the form when the organization is missing" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Role.count } do
          post "/application/administration/roles", params: { role: { moduler_organization_id: "", name: "Editor" } }
        end

        assert_response :unprocessable_entity
        assert_select "div.text-red-500", text: "must exist"
      end

      test "create re-renders the form when the role is invalid" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Role.count } do
          post "/application/administration/roles", params: { role: { moduler_organization_id: @organization.id, name: "", permissions: [ "unknown" ] } }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/roles']"
      end

      test "create re-renders the form when the name is already taken in the organization" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Role.count } do
          post "/application/administration/roles", params: { role: { moduler_organization_id: @organization.id, name: "Owner" } }
        end

        assert_response :unprocessable_entity
        assert_match "has already been taken", response.body
      end

      test "create responds with bad request when role params are missing" do
        sign_in_as @administrator

        post "/application/administration/roles"

        assert_response :bad_request
      end

      test "create redirects a member to the home page" do
        sign_in_as @member

        assert_no_difference -> { Moduler::Role.count } do
          post "/application/administration/roles", params: { role: { moduler_organization_id: @organization.id, name: "Editor" } }
        end

        assert_redirected_to "/application/"
      end

      test "edit renders the form with the locked organization and checked permissions" do
        sign_in_as @administrator
        role = moduler_roles(:acme_viewer)

        get "/application/administration/roles/#{role.id}/edit"

        assert_response :success
        assert_select "form[action='/application/administration/roles/#{role.id}']" do
          assert_select "input[name='_method'][value='patch']"
          assert_select "select[name='role[moduler_organization_id]']", count: 0
          assert_select "#role_organization", text: "Acme"
          assert_select "input[name='role[name]'][value='Viewer']"
          assert_select "input[type='checkbox'][checked]", count: 1
          assert_select "input[type='checkbox'][value='tasks.read'][checked]"
        end
      end

      test "edit responds with not found for an unknown role" do
        sign_in_as @administrator

        get "/application/administration/roles/0/edit"

        assert_response :not_found
      end

      test "edit redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/roles/#{@role.id}/edit"

        assert_redirected_to "/application/"
      end

      test "update changes the name and permissions and redirects to the list" do
        sign_in_as @administrator

        patch "/application/administration/roles/#{@role.id}", params: { role: { name: "Administrator", permissions: [ "", "tasks.read" ] } }

        assert_redirected_to "/application/administration/roles"
        assert_equal "Role has been updated", flash[:notice]
        @role.reload
        assert_equal "Administrator", @role.name
        assert_equal %w[ tasks.read ], @role.permissions
      end

      test "update removes all permissions" do
        sign_in_as @administrator

        patch "/application/administration/roles/#{@role.id}", params: { role: { permissions: [ "" ] } }

        assert_redirected_to "/application/administration/roles"
        assert_equal [], @role.reload.permissions
      end

      test "update does not change the organization" do
        sign_in_as @administrator

        assert_no_changes -> { @role.reload.moduler_organization_id } do
          patch "/application/administration/roles/#{@role.id}", params: { role: { moduler_organization_id: moduler_organizations(:globex).id, name: "Owner" } }
        end
      end

      test "update re-renders the form when the role is invalid" do
        sign_in_as @administrator

        assert_no_changes -> { @role.reload.permissions } do
          patch "/application/administration/roles/#{@role.id}", params: { role: { permissions: [ "unknown" ] } }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/roles/#{@role.id}']"
      end

      test "update redirects a member to the home page" do
        sign_in_as @member

        assert_no_changes -> { @role.reload.name } do
          patch "/application/administration/roles/#{@role.id}", params: { role: { name: "Hacked" } }
        end

        assert_redirected_to "/application/"
      end

      test "destroy is not routable" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Role.count } do
          delete "/application/administration/roles/#{@role.id}"
        end

        assert_response :not_found
      end
    end
  end
end
