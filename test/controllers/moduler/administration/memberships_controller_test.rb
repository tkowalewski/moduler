require "test_helper"

module Moduler
  module Administration
    class MembershipsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
        @organization = moduler_organizations(:acme)
        @globex = moduler_organizations(:globex)
        @membership = moduler_memberships(:default_acme)
        @candidate = Moduler::User.create!(email_address: "candidate@domain.tld", password: "password123")
      end

      def membership_params(**overrides)
        { moduler_organization_id: @organization.id, moduler_user_id: @candidate.id, moduler_role_id: moduler_roles(:acme_viewer).id }.merge(overrides)
      end

      test "index redirects a guest to the sign in page" do
        get "/application/administration/memberships"

        assert_redirected_to "/application/session/new"
      end

      test "index redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/memberships"

        assert_redirected_to "/application/"
      end

      test "index lists members of all organizations for an administrator" do
        sign_in_as @administrator
        globex_membership = Moduler::Membership.create!(user: @candidate, organization: @globex, role: moduler_roles(:globex_owner))

        get "/application/administration/memberships"

        assert_response :success
        assert_select "#memberships > li", count: 2
        assert_select "##{dom_id(@membership)}" do
          assert_select "p", text: @member.email_address
          assert_select "span", text: "Acme"
          assert_select "span", text: "Owner"
          assert_select "a[href='/application/administration/memberships/#{@membership.id}/edit']"
          assert_select "form[action='/application/administration/memberships/#{@membership.id}'] input[name='_method'][value='delete']"
        end
        assert_select "##{dom_id(globex_membership)}", text: /Globex/
        assert_select "a[href='/application/administration/memberships/new']"
      end

      test "index links the members page in the sidebar" do
        sign_in_as @administrator

        get "/application/administration/memberships"

        assert_select "aside a.bg-slate-100[href='/application/administration/memberships']", text: "Members"
      end

      test "index filters members by organization" do
        sign_in_as @administrator
        Moduler::Membership.create!(user: @candidate, organization: @globex, role: moduler_roles(:globex_owner))

        get "/application/administration/memberships", params: { filter: { organization_id: @globex.id } }

        assert_response :success
        assert_select "#memberships > li", count: 1
        assert_select "#memberships", text: /candidate@domain.tld/
        assert_select "select[name='filter[organization_id]'] option[selected][value='#{@globex.id}']"
        assert_select "a[href='/application/administration/memberships/new?organization_id=#{@globex.id}']"
      end

      test "index filters members by email address" do
        sign_in_as @administrator
        Moduler::Membership.create!(user: @candidate, organization: @organization, role: moduler_roles(:acme_viewer))

        get "/application/administration/memberships", params: { filter: { query: "candidate" } }

        assert_response :success
        assert_select "#memberships > li", count: 1
        assert_select "#memberships", text: /candidate@domain.tld/
      end

      test "index renders an empty state when no members match the filter" do
        sign_in_as @administrator

        get "/application/administration/memberships", params: { filter: { organization_id: @globex.id } }

        assert_response :success
        assert_select "#memberships", count: 0
        assert_match "No members found", response.body
      end

      test "new renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/memberships/new"

        assert_response :success
        assert_select "form[action='/application/administration/memberships']" do
          assert_select "select[name='membership[moduler_organization_id]'] option[value='#{@organization.id}']", text: "Acme"
          assert_select "select[name='membership[moduler_user_id]'] option[value='#{@candidate.id}']", text: @candidate.email_address
          assert_select "select[name='membership[moduler_user_id]'] option[value='#{@administrator.id}']", count: 0
        end
      end

      test "new renders no roles until an organization is chosen" do
        sign_in_as @administrator

        get "/application/administration/memberships/new"

        assert_select "select[name='membership[moduler_role_id]'] option", count: 1
        assert_select "select[name='membership[moduler_role_id]'] option[value='']"
      end

      test "new connects the organization and role selects" do
        sign_in_as @administrator

        get "/application/administration/memberships/new"

        assert_select "[data-controller='dependent-select']" do |elements|
          roles = JSON.parse(elements.first["data-dependent-select-options-value"])
          assert_equal [ [ "Owner", moduler_roles(:acme_owner).id ], [ "Viewer", moduler_roles(:acme_viewer).id ] ], roles[@organization.id]
          assert_equal [ [ "Owner", moduler_roles(:globex_owner).id ] ], roles[@globex.id]

          assert_select "select[name='membership[moduler_organization_id]'][data-dependent-select-target='source'][data-action='dependent-select#update']"
          assert_select "select[name='membership[moduler_role_id]'][data-dependent-select-target='dependent']"
        end
      end

      test "new preselects the organization from params and renders its roles" do
        sign_in_as @administrator

        get "/application/administration/memberships/new", params: { organization_id: @globex.id }

        assert_select "select[name='membership[moduler_organization_id]'] option[selected][value='#{@globex.id}']"
        assert_select "select[name='membership[moduler_role_id]']" do
          assert_select "option", count: 2
          assert_select "option[value='#{moduler_roles(:globex_owner).id}']", text: "Owner"
        end
      end

      test "new redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/memberships/new"

        assert_redirected_to "/application/"
      end

      test "create adds a member to the organization and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { @organization.memberships.count }, 1 do
          post "/application/administration/memberships", params: { membership: membership_params }
        end

        assert_redirected_to "/application/administration/memberships"
        assert_equal "Member has been added", flash[:notice]
        assert_equal moduler_roles(:acme_viewer), @organization.memberships.find_by!(user: @candidate).role
      end

      test "create re-renders the form when the organization, user and role are missing" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Membership.count } do
          post "/application/administration/memberships", params: { membership: { moduler_organization_id: "", moduler_user_id: "", moduler_role_id: "" } }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/memberships']"
        assert_select "div.text-red-500", text: "must exist", count: 3
      end

      test "create rejects an administrator" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Membership.count } do
          post "/application/administration/memberships", params: { membership: membership_params(moduler_user_id: @administrator.id) }
        end

        assert_response :unprocessable_entity
        assert_match "must have the member role", response.body
        assert_select "select[name='membership[moduler_role_id]'] option[selected][value='#{moduler_roles(:acme_viewer).id}']"
      end

      test "create rejects a role of another organization" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Membership.count } do
          post "/application/administration/memberships", params: { membership: membership_params(moduler_role_id: moduler_roles(:globex_owner).id) }
        end

        assert_response :unprocessable_entity
        assert_select "div.text-red-500", text: "is not included in the list"
      end

      test "create rejects a user who already belongs to the organization" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Membership.count } do
          post "/application/administration/memberships", params: { membership: membership_params(moduler_user_id: @member.id) }
        end

        assert_response :unprocessable_entity
        assert_select "div.text-red-500", text: "has already been taken"
      end

      test "create responds with bad request when membership params are missing" do
        sign_in_as @administrator

        post "/application/administration/memberships"

        assert_response :bad_request
      end

      test "create redirects a member to the home page" do
        sign_in_as @member

        assert_no_difference -> { Moduler::Membership.count } do
          post "/application/administration/memberships", params: { membership: membership_params }
        end

        assert_redirected_to "/application/"
      end

      test "edit renders the form with the locked organization and user" do
        sign_in_as @administrator

        get "/application/administration/memberships/#{@membership.id}/edit"

        assert_response :success
        assert_select "form[action='/application/administration/memberships/#{@membership.id}']" do
          assert_select "input[name='_method'][value='patch']"
          assert_select "select[name='membership[moduler_organization_id]']", count: 0
          assert_select "select[name='membership[moduler_user_id]']", count: 0
          assert_select "#membership_organization", text: "Acme"
          assert_select "#membership_user", text: @member.email_address
          assert_select "select[name='membership[moduler_role_id]'] option", count: @organization.roles.count
          assert_select "select[name='membership[moduler_role_id]'] option[selected][value='#{moduler_roles(:acme_owner).id}']"
        end
      end

      test "edit responds with not found for an unknown membership" do
        sign_in_as @administrator

        get "/application/administration/memberships/0/edit"

        assert_response :not_found
      end

      test "edit redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/memberships/#{@membership.id}/edit"

        assert_redirected_to "/application/"
      end

      test "update changes the role and redirects to the list" do
        sign_in_as @administrator

        patch "/application/administration/memberships/#{@membership.id}", params: { membership: { moduler_role_id: moduler_roles(:acme_viewer).id } }

        assert_redirected_to "/application/administration/memberships"
        assert_equal "Member has been updated", flash[:notice]
        assert_equal moduler_roles(:acme_viewer), @membership.reload.role
      end

      test "update does not change the organization or user" do
        sign_in_as @administrator

        assert_no_changes -> { @membership.reload.attributes.slice("moduler_organization_id", "moduler_user_id") } do
          patch "/application/administration/memberships/#{@membership.id}", params: {
            membership: { moduler_organization_id: @globex.id, moduler_user_id: @candidate.id, moduler_role_id: moduler_roles(:acme_viewer).id }
          }
        end
      end

      test "update re-renders the form with a role of another organization" do
        sign_in_as @administrator

        assert_no_changes -> { @membership.reload.moduler_role_id } do
          patch "/application/administration/memberships/#{@membership.id}", params: { membership: { moduler_role_id: moduler_roles(:globex_owner).id } }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/memberships/#{@membership.id}']"
      end

      test "update redirects a member to the home page" do
        sign_in_as @member

        assert_no_changes -> { @membership.reload.moduler_role_id } do
          patch "/application/administration/memberships/#{@membership.id}", params: { membership: { moduler_role_id: moduler_roles(:acme_viewer).id } }
        end

        assert_redirected_to "/application/"
      end

      test "destroy removes the member and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { Moduler::Membership.count }, -1 do
          delete "/application/administration/memberships/#{@membership.id}"
        end

        assert_redirected_to "/application/administration/memberships"
        assert_equal "Member has been removed", flash[:notice]
        assert Moduler::User.exists?(@member.id)
      end

      test "destroy redirects a member to the home page" do
        sign_in_as @member

        assert_no_difference -> { Moduler::Membership.count } do
          delete "/application/administration/memberships/#{@membership.id}"
        end

        assert_redirected_to "/application/"
      end
    end
  end
end
