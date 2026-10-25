require "test_helper"

module Moduler
  module Administration
    class UsersControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "index redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/users"

        assert_redirected_to "/application/"
      end

      test "index succeeds for an administrator" do
        sign_in_as @administrator

        get "/application/administration/users"

        assert_response :success
      end

      test "index lists users" do
        sign_in_as @administrator

        get "/application/administration/users"

        assert_select "#users > li", count: Moduler::User.count
        assert_select "#users", text: /#{@member.email_address}/
        assert_select "a[href='/application/administration/users/#{@member.id}/edit']"
      end

      test "index filters users by query" do
        sign_in_as @administrator

        get "/application/administration/users", params: { filter: { query: "test@" } }

        assert_response :success
        assert_select "#users > li", count: 1
        assert_select "#users", text: /#{@member.email_address}/
      end

      test "index renders an empty state when no users match the query" do
        sign_in_as @administrator

        get "/application/administration/users", params: { filter: { query: "nobody@example.com" } }

        assert_response :success
        assert_select "#users", count: 0
      end

      test "index paginates users" do
        sign_in_as @administrator
        12.times { |i| Moduler::User.create!(email_address: "user#{i}@domain.tld", password: "password123") }

        get "/application/administration/users"

        assert_select "#users > li", count: 10
        assert_select "nav[aria-label='Pagination'] a[rel='next']"

        get "/application/administration/users", params: { page: 2 }

        assert_select "#users > li", count: Moduler::User.count - 10
      end

      test "new redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/users/new"

        assert_redirected_to "/application/"
      end

      test "new renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/users/new"

        assert_response :success
        assert_select "form[action='/application/administration/users']" do
          assert_select "input[name='user[email_address]']"
          assert_select "select[name='user[role]'] option", count: Moduler::User.roles.size
          assert_select "input[name='user[password]']"
        end
      end

      test "create creates a user and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { Moduler::User.count }, 1 do
          post "/application/administration/users", params: {
            user: { email_address: "new@domain.tld", role: "administrator", password: "password123" }
          }
        end

        assert_redirected_to "/application/administration/users"
        user = Moduler::User.find_by!(email_address: "new@domain.tld")
        assert user.administrator?
        assert user.authenticate("password123")
      end

      test "create re-renders the form when the user is invalid" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::User.count } do
          post "/application/administration/users", params: {
            user: { email_address: @member.email_address, role: "member", password: "short" }
          }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/users']"
      end

      test "edit renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/users/#{@member.id}/edit"

        assert_response :success
        assert_select "form[action='/application/administration/users/#{@member.id}']" do
          assert_select "input[name='_method'][value='patch']"
          assert_select "input[name='user[email_address]'][value='#{@member.email_address}']"
          assert_select "select[name='user[role]'] option[selected][value='member']"
          assert_select "input[name='user[password]']", count: 0
        end
      end

      test "edit responds with not found for an unknown user" do
        sign_in_as @administrator

        get "/application/administration/users/#{SecureRandom.uuid}/edit"

        assert_response :not_found
      end

      test "update changes email address and role and redirects to the list" do
        sign_in_as @administrator

        patch "/application/administration/users/#{@member.id}", params: {
          user: { email_address: "changed@domain.tld", role: "administrator" }
        }

        assert_redirected_to "/application/administration/users"
        @member.reload
        assert_equal "changed@domain.tld", @member.email_address
        assert @member.administrator?
      end

      test "index does not render the edit link for the current user" do
        sign_in_as @administrator

        get "/application/administration/users"

        assert_select "a[href='/application/administration/users/#{@administrator.id}/edit']", count: 0
        assert_select "a[href='/application/administration/users/#{@member.id}/edit']"
      end

      test "edit redirects an administrator editing themselves to the home page" do
        sign_in_as @administrator

        get "/application/administration/users/#{@administrator.id}/edit"

        assert_redirected_to "/application/"
      end

      test "update does not allow an administrator to update themselves" do
        sign_in_as @administrator

        assert_no_changes -> { @administrator.reload.role } do
          patch "/application/administration/users/#{@administrator.id}", params: {
            user: { email_address: @administrator.email_address, role: "member" }
          }
        end

        assert_redirected_to "/application/"
      end

      test "update ignores password" do
        sign_in_as @administrator

        assert_no_changes -> { @member.reload.password_digest } do
          patch "/application/administration/users/#{@member.id}", params: {
            user: { email_address: @member.email_address, role: "member", password: "newpassword123" }
          }
        end
      end

      test "update re-renders the form when the user is invalid" do
        sign_in_as @administrator

        assert_no_changes -> { @member.reload.email_address } do
          patch "/application/administration/users/#{@member.id}", params: {
            user: { email_address: @administrator.email_address, role: "member" }
          }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/users/#{@member.id}']"
      end

      test "create redirects a member to the home page" do
        sign_in_as @member

        post "/application/administration/users"

        assert_redirected_to "/application/"
      end

      test "edit redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/users/#{@member.id}/edit"

        assert_redirected_to "/application/"
      end

      test "update redirects a member to the home page" do
        sign_in_as @member

        patch "/application/administration/users/#{@member.id}"

        assert_redirected_to "/application/"
      end
    end
  end
end
