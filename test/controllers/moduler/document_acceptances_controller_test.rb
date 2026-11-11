require "test_helper"

module Moduler
  class DocumentAcceptancesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @member = moduler_users(:default)
      @administrator = moduler_users(:administrator)
      @privacy_policy = moduler_documents(:privacy_policy)
      @terms = moduler_documents(:terms_and_conditions)
      @privacy_policy.file.attach(io: file_fixture("document.pdf").open, filename: "privacy-policy.pdf", content_type: "application/pdf")

      Moduler::UserDocument.where(user: @member).delete_all
    end

    def accept_documents(user, documents)
      documents.each { |document| Moduler::UserDocument.create!(user: user, document: document) }
    end

    def accept(*documents)
      post "/application/document_acceptance", params: { document_acceptance: { document_ids: documents.map(&:id) } }
    end

    # Access to the document acceptance page

    test "new redirects a guest to the sign in page" do
      get "/application/document_acceptance/new"

      assert_redirected_to "/application/session/new"
    end

    test "new lists the pending documents" do
      sign_in_as @member

      get "/application/document_acceptance/new"

      assert_response :success
      assert_select "form[action='/application/document_acceptance'][method='post']" do
        assert_select "input[name='_method']", count: 0
        assert_select "input[type='checkbox'][name='document_acceptance[document_ids][]']", count: 2
        assert_select "input[type='checkbox'][value='#{@privacy_policy.id}']:not([checked])"
        assert_select "label[for='document_acceptance_document_#{@privacy_policy.id}']", text: "I have read and accept: #{@privacy_policy.name}"
      end
      assert_select "##{dom_id(@privacy_policy)} a[href*='privacy-policy.pdf'][target='_blank']", text: "Read the document"
      assert_select "##{dom_id(@terms)} a", text: "Read the document", count: 0
    end

    test "new lists only the documents the user has not accepted" do
      accept_documents(@member, [ @privacy_policy ])
      sign_in_as @member

      get "/application/document_acceptance/new"

      assert_select "input[type='checkbox'][name='document_acceptance[document_ids][]']", count: 1
      assert_select "input[type='checkbox'][value='#{@terms.id}']"
    end

    test "new renders no documents when there is nothing to accept" do
      accept_documents(@member, [ @privacy_policy, @terms ])
      sign_in_as @member

      get "/application/document_acceptance/new"

      assert_response :success
      assert_select "input[type='checkbox']", count: 0
    end

    # Accepting documents

    test "create accepts all pending documents and redirects to the home page" do
      sign_in_as @member

      assert_difference -> { @member.user_documents.count }, 2 do
        accept @privacy_policy, @terms
      end

      assert_redirected_to "/application/"
      assert_equal "Thank you. You can now use the panel.", flash[:notice]
      assert_empty @member.pending_documents

      follow_redirect!

      assert_response :success
    end

    test "create does not accept anything when a document is not checked" do
      sign_in_as @member

      assert_no_difference -> { Moduler::UserDocument.count } do
        accept @privacy_policy
      end

      assert_response :unprocessable_entity
      assert_match "Accept all documents to continue.", response.body
      assert_select "input[type='checkbox'][value='#{@privacy_policy.id}'][checked]"
      assert_select "input[type='checkbox'][value='#{@terms.id}']:not([checked])"
    end

    test "create does not accept anything when no document is checked" do
      sign_in_as @member

      assert_no_difference -> { Moduler::UserDocument.count } do
        post "/application/document_acceptance"
      end

      assert_response :unprocessable_entity
    end

    test "create requires a document created after the document acceptance page was shown" do
      sign_in_as @member
      get "/application/document_acceptance/new"
      document = Moduler::Document.new(name: "Data processing agreement", kind: "data_processing_agreement")
      document.file.attach(io: file_fixture("document.pdf").open, filename: "document.pdf", content_type: "application/pdf")
      document.save!

      assert_no_difference -> { Moduler::UserDocument.count } do
        accept @privacy_policy, @terms
      end

      assert_response :unprocessable_entity
      assert_select "input[type='checkbox'][value='#{document.id}']"
    end

    test "create ignores unknown and already accepted document ids" do
      accept_documents(@member, [ @privacy_policy ])
      sign_in_as @member

      assert_difference -> { Moduler::UserDocument.count }, 1 do
        post "/application/document_acceptance", params: { document_acceptance: { document_ids: [ @privacy_policy.id, @terms.id, 0 ] } }
      end

      assert_redirected_to "/application/"
    end

    test "create accepts documents only for the current user" do
      sign_in_as @member

      assert_no_difference -> { @administrator.user_documents.count } do
        accept @privacy_policy, @terms
      end
    end

    test "create succeeds without changes when there is nothing to accept" do
      accept_documents(@member, [ @privacy_policy, @terms ])
      sign_in_as @member

      assert_no_difference -> { Moduler::UserDocument.count } do
        accept @privacy_policy, @terms
      end

      assert_redirected_to "/application/"
    end

    test "create redirects a guest to the sign in page" do
      assert_no_difference -> { Moduler::UserDocument.count } do
        accept @privacy_policy, @terms
      end

      assert_redirected_to "/application/session/new"
    end

    # Access to the panel while document acceptance is pending

    test "signing in redirects to the document acceptance through the home page" do
      sign_in_as @member

      assert_redirected_to "/application/"
      follow_redirect!

      assert_redirected_to "/application/document_acceptance/new"
    end

    test "the home page is blocked until the documents are accepted" do
      sign_in_as @member

      get "/application/"

      assert_redirected_to "/application/document_acceptance/new"
    end

    test "the panel becomes blocked when a new document is created" do
      accept_documents(@member, [ @privacy_policy, @terms ])
      sign_in_as @member

      get "/application/"
      assert_response :success

      document = Moduler::Document.new(name: "Data processing agreement", kind: "data_processing_agreement")
      document.file.attach(io: file_fixture("document.pdf").open, filename: "document.pdf", content_type: "application/pdf")
      document.save!

      get "/application/"
      assert_redirected_to "/application/document_acceptance/new"
    end

    test "the home page is available when every document is accepted" do
      accept_documents(@member, [ @privacy_policy, @terms ])
      sign_in_as @member

      get "/application/"

      assert_response :success
    end

    test "the profile is available during document acceptance" do
      sign_in_as @member

      get "/application/profile/edit"
      assert_response :success

      patch "/application/profile", params: {
        user: { password_challenge: "password123", password: "newpassword1", password_confirmation: "newpassword1" }
      }
      assert_redirected_to "/application/profile/edit"
    end

    test "the profile sessions are available during document acceptance" do
      sign_in_as @member

      get "/application/profile/sessions"
      assert_response :success

      delete "/application/profile/sessions/#{@member.sessions.order(signed_in_at: :desc).first.id}"
      assert_redirected_to "/application/session/new"
    end

    test "revoking all sessions is available during document acceptance" do
      sign_in_as @member

      delete "/application/profile/sessions/revocation"

      assert_redirected_to "/application/session/new"
      assert_empty @member.sessions.active
    end

    test "signing out is available during document acceptance" do
      sign_in_as @member

      delete "/application/session"

      assert_redirected_to "/application/session/new"
      assert cookies[:session_id].blank?
    end

    test "the public articles are not blocked during document acceptance" do
      sign_in_as @member

      get "/application/articles"
      assert_response :success

      get "/application/articles/#{moduler_articles(:default).path}"
      assert_response :success
    end

    test "the administration is available to an administrator during document acceptance" do
      assert_not_empty @administrator.pending_documents
      sign_in_as @administrator

      get "/application/administration"
      assert_response :success

      get "/application/administration/documents"
      assert_response :success

      get "/application/administration/tasks"
      assert_response :success
    end

    test "the home page redirects an administrator with pending documents to the administration" do
      assert_not_empty @administrator.pending_documents
      sign_in_as @administrator

      get "/application/"

      assert_redirected_to "/application/administration"
    end

    test "the administration is blocked for a member during document acceptance" do
      sign_in_as @member

      get "/application/administration"

      assert_redirected_to "/application/document_acceptance/new"
    end
  end
end
