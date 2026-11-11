require "test_helper"

module Moduler
  module Profile
    class SentEmailsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = moduler_users(:default)
        @sent_email = moduler_sent_emails(:default_newsletter)
      end

      test "index redirects a guest to the sign in page" do
        get "/application/profile/sent_emails"

        assert_redirected_to "/application/session/new"
      end

      test "index lists the emails sent to the signed-in user" do
        sign_in_as @user

        get "/application/profile/sent_emails"

        assert_response :success
        assert_select "#sent_emails > li", count: 1
        assert_select "##{dom_id(@sent_email)}" do
          assert_select "p", text: "November news"
          assert_select "a[href='/application/profile/sent_emails/#{@sent_email.id}'][target='_blank']", text: "View"
        end
        assert_select "##{dom_id(moduler_sent_emails(:administrator_notice))}", count: 0
        assert_select "aside a.bg-slate-100[href='/application/profile/sent_emails']", text: "Emails"
      end

      test "index links the attachments of a sent email for download" do
        @sent_email.attachments.attach(io: file_fixture("document.pdf").open, filename: "terms.pdf", content_type: "application/pdf")
        sign_in_as @user

        get "/application/profile/sent_emails"

        assert_select "##{dom_id(@sent_email)} a[href^='/rails/active_storage/blobs/'][href*='terms.pdf'][href*='disposition=attachment']", text: "terms.pdf"
      end

      test "index does not link attachments of an email without them" do
        sign_in_as @user

        get "/application/profile/sent_emails"

        assert_select "##{dom_id(@sent_email)} a[href^='/rails/active_storage/blobs/']", count: 0
      end

      test "index renders an empty message without emails" do
        @user.sent_emails.delete_all
        sign_in_as @user

        get "/application/profile/sent_emails"

        assert_select "#sent_emails", count: 0
        assert_match "No emails have been sent to you yet.", response.body
      end

      test "index is available to an administrator" do
        sign_in_as moduler_users(:administrator)

        get "/application/profile/sent_emails"

        assert_response :success
        assert_select "##{dom_id(moduler_sent_emails(:administrator_notice))}"
      end

      test "show renders an email sent to the signed-in user" do
        sign_in_as @user

        get "/application/profile/sent_emails/#{@sent_email.id}"

        assert_response :success
        assert_equal @sent_email.body, response.body
      end

      test "show responds with not found for an email sent to someone else" do
        sign_in_as @user

        get "/application/profile/sent_emails/#{moduler_sent_emails(:administrator_notice).id}"

        assert_response :not_found
      end
    end
  end
end
