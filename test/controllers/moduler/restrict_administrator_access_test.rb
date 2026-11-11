require "test_helper"

module Moduler
  class RestrictAdministratorAccessTest < ActionDispatch::IntegrationTest
    setup do
      @member = moduler_users(:default)
      @administrator = moduler_users(:administrator)
    end

    test "redirects an administrator from the home page to the administration area" do
      sign_in_as @administrator

      get "/application/"

      assert_redirected_to "/application/administration"
    end

    test "redirects an administrator from the document acceptance page to the administration area" do
      sign_in_as @administrator

      get "/application/document_acceptance/new"

      assert_redirected_to "/application/administration"
    end

    test "lets a member use the home page" do
      sign_in_as @member
      Moduler::Document.find_each { |document| @member.user_documents.find_or_create_by!(document: document) }

      get "/application/"

      assert_response :success
    end

    test "lets an administrator use the administration area" do
      sign_in_as @administrator

      get "/application/administration"

      assert_response :success
    end

    test "lets an administrator use administration resources of the host application" do
      sign_in_as @administrator

      get "/application/administration/tasks"

      assert_response :success
    end

    test "lets an administrator use the profile and its sessions" do
      sign_in_as @administrator

      get "/application/profile/edit"
      assert_response :success

      get "/application/profile/sessions"
      assert_response :success
    end

    test "lets an administrator read published articles" do
      sign_in_as @administrator

      get "/application/articles"
      assert_response :success

      get "/application/articles/#{moduler_articles(:default).path}"
      assert_response :success
    end

    test "lets an administrator sign out" do
      sign_in_as @administrator

      delete "/application/session"

      assert_redirected_to "/application/session/new"
    end

    test "header links home to the administration area for an administrator" do
      sign_in_as @administrator

      get "/application/administration"

      assert_select "nav a[href='/application/administration']", text: "Home"
      assert_select "nav a", text: "Administration", count: 0
    end

    test "header links home to the application for a member" do
      sign_in_as @member

      get "/application/profile/edit"

      assert_select "nav a[href='/application/']", text: "Home"
      assert_select "nav a", text: "Administration", count: 0
    end
  end
end
