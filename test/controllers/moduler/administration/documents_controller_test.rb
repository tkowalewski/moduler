require "test_helper"

module Moduler
  module Administration
    class DocumentsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
        @document = moduler_documents(:privacy_policy)
        @document.file.attach(io: file_fixture("document.pdf").open, filename: "privacy-policy.pdf", content_type: "application/pdf")
      end

      def pdf_upload
        fixture_file_upload("document.pdf", "application/pdf")
      end

      def document_params(**overrides)
        { name: "Data processing agreement", kind: "data_processing_agreement", file: pdf_upload }.merge(overrides)
      end

      def create_document(name:, kind: "privacy_policy")
        Moduler::Document.new(name: name, kind: kind).tap do |document|
          document.file.attach(io: file_fixture("document.pdf").open, filename: "document.pdf", content_type: "application/pdf")
          document.save!
        end
      end

      test "index redirects a guest to the sign in page" do
        get "/application/administration/documents"

        assert_redirected_to "/application/session/new"
      end

      test "index redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/documents"

        assert_redirected_to "/application/"
      end

      test "index lists documents for an administrator" do
        sign_in_as @administrator

        get "/application/administration/documents"

        assert_response :success
        assert_select "#documents > li", count: Moduler::Document.count
        assert_select "##{dom_id(@document)}" do
          assert_select "p", text: @document.name
          assert_select "span", text: "Privacy policy"
          assert_select "a[href^='/rails/active_storage/blobs/'][href*='privacy-policy.pdf']", text: "Download"
          assert_select "a[href='/application/administration/documents/#{@document.id}/edit']"
        end
        assert_select "a[href='/application/administration/documents/new']"
      end

      test "index does not render a download link for a document without a file" do
        sign_in_as @administrator

        get "/application/administration/documents"

        assert_select "##{dom_id(moduler_documents(:terms_and_conditions))} a", text: "Download", count: 0
      end

      test "index links the documents page in the sidebar" do
        sign_in_as @administrator

        get "/application/administration/documents"

        assert_select "aside a[href='/application/administration/documents']", text: "Documents"
      end

      test "index filters documents by query" do
        sign_in_as @administrator

        get "/application/administration/documents", params: { filter: { query: "Privacy" } }

        assert_response :success
        assert_select "#documents > li", count: 1
        assert_select "#documents", text: /#{@document.name}/
      end

      test "index renders an empty state when no documents match the query" do
        sign_in_as @administrator

        get "/application/administration/documents", params: { filter: { query: "zzzzzz" } }

        assert_response :success
        assert_select "#documents", count: 0
        assert_match "No documents found", response.body
      end

      test "index paginates documents" do
        sign_in_as @administrator
        12.times { |i| create_document(name: "Document #{i}") }

        get "/application/administration/documents"

        assert_select "#documents > li", count: 10
        assert_select "nav[aria-label='Pagination'] a[rel='next']"

        get "/application/administration/documents", params: { page: 2 }

        assert_select "#documents > li", count: Moduler::Document.count - 10
      end

      test "new redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/documents/new"

        assert_redirected_to "/application/"
      end

      test "new renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/documents/new"

        assert_response :success
        assert_select "form[action='/application/administration/documents'][enctype='multipart/form-data']" do
          assert_select "input[name='document[name]']"
          assert_select "select[name='document[kind]'] option", count: Moduler::Document::KINDS.size
          assert_select "select[name='document[kind]'] option[value='terms_and_conditions']", text: "Terms and conditions"
          assert_select "input[type='file'][name='document[file]'][accept='application/pdf']"
        end
        assert_match "PDF, smaller than 10 MB. The file cannot be changed after the document is created.", response.body
      end

      test "create creates a document and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { Moduler::Document.count }, 1 do
          post "/application/administration/documents", params: { document: document_params }
        end

        assert_redirected_to "/application/administration/documents"
        assert_equal "Document has been created", flash[:notice]
        document = Moduler::Document.find_by!(name: "Data processing agreement")
        assert_equal "data_processing_agreement", document.kind
        assert document.file.attached?
        assert_equal "application/pdf", document.file.content_type
      end

      test "create re-renders the form when the document is invalid" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Document.count } do
          post "/application/administration/documents", params: { document: document_params(name: "", kind: "unknown") }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/documents']"
      end

      test "create re-renders the form when the file is missing" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Document.count } do
          post "/application/administration/documents", params: { document: document_params.except(:file) }
        end

        assert_response :unprocessable_entity
      end

      test "create rejects a file with a disallowed content type" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Document.count } do
          post "/application/administration/documents", params: {
            document: document_params(file: fixture_file_upload("document.txt", "text/plain"))
          }
        end

        assert_response :unprocessable_entity
      end

      test "create responds with bad request when document params are missing" do
        sign_in_as @administrator

        post "/application/administration/documents"

        assert_response :bad_request
      end

      test "create redirects a member to the home page" do
        sign_in_as @member

        assert_no_difference -> { Moduler::Document.count } do
          post "/application/administration/documents", params: { document: document_params }
        end

        assert_redirected_to "/application/"
      end

      test "edit renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/documents/#{@document.id}/edit"

        assert_response :success
        assert_select "form[action='/application/administration/documents/#{@document.id}']" do
          assert_select "input[name='_method'][value='patch']"
          assert_select "input[name='document[name]'][value='#{@document.name}']"
          assert_select "select[name='document[kind]'] option[selected][value='privacy_policy']"
          assert_select "input[type='file']", count: 0
          assert_select "#document_file", text: "privacy-policy.pdf"
        end
        assert_match "The file cannot be changed.", response.body
      end

      test "edit responds with not found for an unknown document" do
        sign_in_as @administrator

        get "/application/administration/documents/0/edit"

        assert_response :not_found
      end

      test "edit redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/documents/#{@document.id}/edit"

        assert_redirected_to "/application/"
      end

      test "update changes the name and kind and redirects to the list" do
        sign_in_as @administrator

        patch "/application/administration/documents/#{@document.id}", params: {
          document: { name: "Privacy policy 2027", kind: "terms_and_conditions" }
        }

        assert_redirected_to "/application/administration/documents"
        assert_equal "Document has been updated", flash[:notice]
        @document.reload
        assert_equal "Privacy policy 2027", @document.name
        assert_equal "terms_and_conditions", @document.kind
      end

      test "update does not replace the file" do
        sign_in_as @administrator

        assert_no_changes -> { @document.reload.file.blob.id } do
          patch "/application/administration/documents/#{@document.id}", params: {
            document: { name: "Privacy policy 2027", file: pdf_upload }
          }
        end

        assert_redirected_to "/application/administration/documents"
        assert_equal "Privacy policy 2027", @document.name
        assert_equal "privacy-policy.pdf", @document.file.filename.to_s
      end

      test "update re-renders the form when the document is invalid" do
        sign_in_as @administrator

        assert_no_changes -> { @document.reload.name } do
          patch "/application/administration/documents/#{@document.id}", params: { document: { name: "" } }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/documents/#{@document.id}']"
      end

      test "update redirects a member to the home page" do
        sign_in_as @member

        assert_no_changes -> { @document.reload.name } do
          patch "/application/administration/documents/#{@document.id}", params: { document: { name: "Hacked" } }
        end

        assert_redirected_to "/application/"
      end

      test "index does not render a destroy button" do
        sign_in_as @administrator

        get "/application/administration/documents"

        assert_select "##{dom_id(@document)} form", count: 0
        assert_select "#documents input[name='_method'][value='delete']", count: 0
      end

      test "destroy is not routable" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Document.count } do
          delete "/application/administration/documents/#{@document.id}"
        end

        assert_response :not_found
      end
    end
  end
end
