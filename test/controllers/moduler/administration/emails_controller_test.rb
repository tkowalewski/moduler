require "test_helper"

module Moduler
  module Administration
    class EmailsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
        @email = moduler_emails(:newsletter)
      end

      def email_params(**overrides)
        { subject: "December news", kind: "newsletter", event: "", sender: "", body: "Hi there" }.merge(overrides)
      end

      test "index redirects a guest to the sign in page" do
        get "/application/administration/emails"

        assert_redirected_to "/application/session/new"
      end

      test "index redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/emails"

        assert_redirected_to "/application/"
      end

      test "index lists emails for an administrator" do
        sign_in_as @administrator

        get "/application/administration/emails"

        assert_response :success
        assert_select "#emails > li", count: Moduler::Email.count
        assert_select "##{dom_id(@email)}" do
          assert_select "p", text: "November news"
          assert_select "span", text: "Newsletter"
          assert_match "Sent to 1 user", response.body
          assert_select "a[href='/application/administration/emails/#{@email.id}/deliveries/new']", text: "Send"
          assert_select "a[href='/application/administration/emails/#{@email.id}/edit']"
          assert_select "form[action='/application/administration/emails/#{@email.id}'] input[name='_method'][value='delete']"
        end
        assert_select "##{dom_id(moduler_emails(:welcome))} span", text: "user.signup"
        assert_select "a[href='/application/administration/emails/new']"
      end

      test "index links the emails page in the sidebar" do
        sign_in_as @administrator

        get "/application/administration/emails"

        assert_select "aside a.bg-slate-100[href='/application/administration/emails']", text: "Emails"
      end

      test "index filters emails by query" do
        sign_in_as @administrator

        get "/application/administration/emails", params: { filter: { query: "November" } }

        assert_select "#emails > li", count: 1
        assert_select "##{dom_id(@email)}"
      end

      test "new renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/emails/new"

        assert_response :success
        assert_select "form[action='/application/administration/emails'][enctype='multipart/form-data']" do
          assert_select "input[name='email[subject]']"
          assert_select "input[name='email[sender]']"
          assert_select "select[name='email[kind]'] option[value='custom']", text: "Custom"
          assert_select "input[type='text'][name='email[event]'][placeholder='order.paid']"
          assert_select "textarea[name='email[body]']"
          assert_select "[data-controller='wysiwyg'][data-wysiwyg-attachments-field-name-value='email[images][]']"
          assert_select "[data-controller='attachments'] template input[type='file'][name='email[attachments][]']:not([multiple])"
          assert_select "[data-controller='attachments'] button[data-action='attachments#add']", text: "Add attachment"
        end
      end

      test "new redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/emails/new"

        assert_redirected_to "/application/"
      end

      test "create creates an email with attachments and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { Moduler::Email.count }, 1 do
          post "/application/administration/emails", params: {
            email: email_params(attachments: [ "", fixture_file_upload("document.pdf", "application/pdf") ])
          }
        end

        assert_redirected_to "/application/administration/emails"
        assert_equal "Email has been created", flash[:notice]
        email = Moduler::Email.find_by!(subject: "December news")
        assert_nil email.event
        assert_nil email.sender
        assert_equal [ "document.pdf" ], email.attachments.map { |attachment| attachment.filename.to_s }
      end

      test "create creates an email with a custom event" do
        sign_in_as @administrator

        post "/application/administration/emails", params: { email: email_params(event: "order.paid") }

        assert_redirected_to "/application/administration/emails"
        assert_equal "order.paid", Moduler::Email.find_by!(subject: "December news").event
      end

      test "create re-renders the form with an event in a wrong format" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Email.count } do
          post "/application/administration/emails", params: { email: email_params(event: "Order Paid") }
        end

        assert_response :unprocessable_entity
        assert_match "is invalid", response.body
      end

      test "create creates an email with one attachment per field, skipping empty fields" do
        sign_in_as @administrator

        post "/application/administration/emails", params: {
          email: email_params(attachments: [ fixture_file_upload("document.pdf", "application/pdf"), "", fixture_file_upload("document.txt", "text/plain") ])
        }

        assert_equal %w[ document.pdf document.txt ], Moduler::Email.find_by!(subject: "December news").attachments.map { |attachment| attachment.filename.to_s }.sort
      end

      test "create ignores attachments marked for removal" do
        sign_in_as @administrator

        assert_difference -> { Moduler::Email.count }, 1 do
          post "/application/administration/emails", params: { email: email_params(remove_attachment_ids: [ "1" ]) }
        end
      end

      test "create re-renders the form when the email is invalid" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Email.count } do
          post "/application/administration/emails", params: { email: email_params(subject: "", event: "user.signup") }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/emails']"
        assert_match "has already been taken", response.body
      end

      test "create responds with bad request when email params are missing" do
        sign_in_as @administrator

        post "/application/administration/emails"

        assert_response :bad_request
      end

      test "create redirects a member to the home page" do
        sign_in_as @member

        assert_no_difference -> { Moduler::Email.count } do
          post "/application/administration/emails", params: { email: email_params }
        end

        assert_redirected_to "/application/"
      end

      test "edit renders the form with the attachments for an administrator" do
        @email.attachments.attach(io: file_fixture("document.pdf").open, filename: "terms.pdf", content_type: "application/pdf")
        sign_in_as @administrator

        get "/application/administration/emails/#{@email.id}/edit"

        assert_response :success
        assert_select "form[action='/application/administration/emails/#{@email.id}'][enctype='multipart/form-data']" do
          assert_select "input[name='_method'][value='patch']"
          assert_select "input[name='email[subject]'][value='November news']"
          assert_select "input[name='email[event]']:not([value])"
          assert_select "select[name='email[kind]'] option[selected][value='newsletter']"
          assert_select "[data-controller='attachments'][data-attachments-remove-field-name-value='email[remove_attachment_ids][]']" do
            assert_select "li[data-attachment-id='#{@email.attachments.first.id}'] a", text: "terms.pdf"
            assert_select "li[data-attachment-id='#{@email.attachments.first.id}'] button[data-action='attachments#remove']", text: "Remove"
          end
        end
      end

      test "edit responds with not found for an unknown email" do
        sign_in_as @administrator

        get "/application/administration/emails/0/edit"

        assert_response :not_found
      end

      test "edit redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/emails/#{@email.id}/edit"

        assert_redirected_to "/application/"
      end

      test "update changes the email and adds attachments to the existing ones" do
        @email.attachments.attach(io: file_fixture("document.pdf").open, filename: "terms.pdf", content_type: "application/pdf")
        sign_in_as @administrator

        patch "/application/administration/emails/#{@email.id}", params: {
          email: { subject: "November news (updated)", attachments: [ "", fixture_file_upload("document.txt", "text/plain") ] }
        }

        assert_redirected_to "/application/administration/emails"
        assert_equal "Email has been updated", flash[:notice]
        @email.reload
        assert_equal "November news (updated)", @email.subject
        assert_equal %w[ document.txt terms.pdf ], @email.attachments.map { |attachment| attachment.filename.to_s }.sort
      end

      test "update keeps the attachments without new files" do
        @email.attachments.attach(io: file_fixture("document.pdf").open, filename: "terms.pdf", content_type: "application/pdf")
        sign_in_as @administrator

        patch "/application/administration/emails/#{@email.id}", params: { email: { subject: "Changed", attachments: [ "" ] } }

        assert_equal 1, @email.reload.attachments.count
      end

      test "update removes the attachments marked for removal" do
        @email.attachments.attach(io: file_fixture("document.pdf").open, filename: "terms.pdf", content_type: "application/pdf")
        @email.attachments.attach(io: file_fixture("document.txt").open, filename: "notes.txt", content_type: "text/plain")
        terms = @email.attachments.find { |attachment| attachment.filename.to_s == "terms.pdf" }
        sign_in_as @administrator

        patch "/application/administration/emails/#{@email.id}", params: {
          email: { subject: "Changed", remove_attachment_ids: [ terms.id ], attachments: [ fixture_file_upload("document.pdf", "application/pdf") ] }
        }

        assert_redirected_to "/application/administration/emails"
        assert_equal %w[ document.pdf notes.txt ], @email.reload.attachments.map { |attachment| attachment.filename.to_s }.sort
      end

      test "update does not remove attachments of another email" do
        other = moduler_emails(:welcome)
        other.attachments.attach(io: file_fixture("document.pdf").open, filename: "other.pdf", content_type: "application/pdf")
        sign_in_as @administrator

        patch "/application/administration/emails/#{@email.id}", params: { email: { remove_attachment_ids: [ other.attachments.first.id ] } }

        assert_redirected_to "/application/administration/emails"
        assert other.reload.attachments.attached?
      end

      test "update does not change attachments when the email is invalid" do
        @email.attachments.attach(io: file_fixture("document.pdf").open, filename: "terms.pdf", content_type: "application/pdf")
        sign_in_as @administrator

        patch "/application/administration/emails/#{@email.id}", params: {
          email: { subject: "", remove_attachment_ids: [ @email.attachments.first.id ], attachments: [ fixture_file_upload("document.txt", "text/plain") ] }
        }

        assert_response :unprocessable_entity
        assert_equal [ "terms.pdf" ], @email.reload.attachments.map { |attachment| attachment.filename.to_s }
      end

      test "update re-renders the form when the email is invalid" do
        sign_in_as @administrator

        assert_no_changes -> { @email.reload.subject } do
          patch "/application/administration/emails/#{@email.id}", params: { email: { subject: "" } }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/emails/#{@email.id}']"
      end

      test "update redirects a member to the home page" do
        sign_in_as @member

        assert_no_changes -> { @email.reload.subject } do
          patch "/application/administration/emails/#{@email.id}", params: { email: { subject: "Hacked" } }
        end

        assert_redirected_to "/application/"
      end

      test "destroy deletes the email and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { Moduler::Email.count }, -1 do
          delete "/application/administration/emails/#{@email.id}"
        end

        assert_redirected_to "/application/administration/emails"
        assert_equal "Email has been deleted", flash[:notice]
      end

      test "destroy redirects a member to the home page" do
        sign_in_as @member

        assert_no_difference -> { Moduler::Email.count } do
          delete "/application/administration/emails/#{@email.id}"
        end

        assert_redirected_to "/application/"
      end
    end
  end
end
