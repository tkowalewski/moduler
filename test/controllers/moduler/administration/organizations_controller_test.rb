require "test_helper"

module Moduler
  module Administration
    class OrganizationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
        @organization = moduler_organizations(:acme)
      end

      test "index redirects a guest to the sign in page" do
        get "/application/administration/organizations"

        assert_redirected_to "/application/session/new"
      end

      test "index redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/organizations"

        assert_redirected_to "/application/"
      end

      test "index lists organizations for an administrator" do
        sign_in_as @administrator

        get "/application/administration/organizations"

        assert_response :success
        assert_select "#organizations > li", count: Moduler::Organization.count
        assert_select "##{dom_id(@organization)}" do
          assert_select "p", text: @organization.name
          assert_select "a[href='/application/administration/organizations/#{@organization.id}/edit']"
        end
        assert_select "a[href='/application/administration/organizations/new']"
      end

      test "index links the organizations page in the sidebar" do
        sign_in_as @administrator

        get "/application/administration/organizations"

        assert_select "aside a[href='/application/administration/organizations']", text: "Organizations"
      end

      test "index filters organizations by query" do
        sign_in_as @administrator

        get "/application/administration/organizations", params: { filter: { query: "Acme" } }

        assert_response :success
        assert_select "#organizations > li", count: 1
        assert_select "#organizations", text: /#{@organization.name}/
      end

      test "index renders an empty state when no organizations match the query" do
        sign_in_as @administrator

        get "/application/administration/organizations", params: { filter: { query: "zzzzzz" } }

        assert_response :success
        assert_select "#organizations", count: 0
        assert_match "No organizations found", response.body
      end

      test "index paginates organizations" do
        sign_in_as @administrator
        12.times { |i| Moduler::Organization.create!(name: "Organization #{i}") }

        get "/application/administration/organizations"

        assert_select "#organizations > li", count: 10
        assert_select "nav[aria-label='Pagination'] a[rel='next']"

        get "/application/administration/organizations", params: { page: 2 }

        assert_select "#organizations > li", count: Moduler::Organization.count - 10
      end

      test "new redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/organizations/new"

        assert_redirected_to "/application/"
      end

      test "new renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/organizations/new"

        assert_response :success
        assert_select "form[action='/application/administration/organizations']" do
          assert_select "input[name='organization[name]']"
        end
      end

      test "create creates an organization and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { Moduler::Organization.count }, 1 do
          post "/application/administration/organizations", params: { organization: { name: "Initech" } }
        end

        assert_redirected_to "/application/administration/organizations"
        assert_equal "Organization has been created", flash[:notice]
        assert Moduler::Organization.exists?(name: "Initech")
      end

      test "create re-renders the form when the name is blank" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Organization.count } do
          post "/application/administration/organizations", params: { organization: { name: "" } }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/organizations']"
      end

      test "create re-renders the form when the name is already taken" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Organization.count } do
          post "/application/administration/organizations", params: { organization: { name: @organization.name } }
        end

        assert_response :unprocessable_entity
        assert_match "has already been taken", response.body
      end

      test "create responds with bad request when organization params are missing" do
        sign_in_as @administrator

        post "/application/administration/organizations"

        assert_response :bad_request
      end

      test "create redirects a member to the home page" do
        sign_in_as @member

        assert_no_difference -> { Moduler::Organization.count } do
          post "/application/administration/organizations", params: { organization: { name: "Initech" } }
        end

        assert_redirected_to "/application/"
      end

      test "edit renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/organizations/#{@organization.id}/edit"

        assert_response :success
        assert_select "form[action='/application/administration/organizations/#{@organization.id}']" do
          assert_select "input[name='_method'][value='patch']"
          assert_select "input[name='organization[name]'][value='#{@organization.name}']"
        end
      end

      test "edit responds with not found for an unknown organization" do
        sign_in_as @administrator

        get "/application/administration/organizations/0/edit"

        assert_response :not_found
      end

      test "edit redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/organizations/#{@organization.id}/edit"

        assert_redirected_to "/application/"
      end

      test "update changes the name and redirects to the list" do
        sign_in_as @administrator

        patch "/application/administration/organizations/#{@organization.id}", params: { organization: { name: "Acme Corporation" } }

        assert_redirected_to "/application/administration/organizations"
        assert_equal "Organization has been updated", flash[:notice]
        assert_equal "Acme Corporation", @organization.reload.name
      end

      test "update re-renders the form when the organization is invalid" do
        sign_in_as @administrator

        assert_no_changes -> { @organization.reload.name } do
          patch "/application/administration/organizations/#{@organization.id}", params: { organization: { name: "" } }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/organizations/#{@organization.id}']"
      end

      test "update re-renders the form when the name is already taken" do
        sign_in_as @administrator

        assert_no_changes -> { @organization.reload.name } do
          patch "/application/administration/organizations/#{@organization.id}", params: { organization: { name: moduler_organizations(:globex).name } }
        end

        assert_response :unprocessable_entity
      end

      test "update redirects a member to the home page" do
        sign_in_as @member

        assert_no_changes -> { @organization.reload.name } do
          patch "/application/administration/organizations/#{@organization.id}", params: { organization: { name: "Hacked" } }
        end

        assert_redirected_to "/application/"
      end

      test "index does not render a destroy button" do
        sign_in_as @administrator

        get "/application/administration/organizations"

        assert_select "##{dom_id(@organization)} form", count: 0
        assert_select "#organizations input[name='_method'][value='delete']", count: 0
      end

      test "destroy is not routable" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Organization.count } do
          delete "/application/administration/organizations/#{@organization.id}"
        end

        assert_response :not_found
      end
    end
  end
end
