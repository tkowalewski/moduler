require "test_helper"

module Moduler
  module Administration
    module Emails
      class DeliveriesControllerTest < ActionDispatch::IntegrationTest
        include ActiveJob::TestHelper

        setup do
          @email = moduler_emails(:newsletter)
          @member = moduler_users(:default)
          @administrator = moduler_users(:administrator)
          @candidate = Moduler::User.create!(email_address: "candidate@domain.tld", password: "password123", name: "Cora Candidate")
          @path = "/application/administration/emails/#{@email.id}/deliveries"
        end

        test "new lists users with their delivery status for an administrator" do
          Moduler::UserEmail.create!(user: @administrator, email: @email)
          sign_in_as @administrator

          get "#{@path}/new"

          assert_response :success
          assert_select "h1", text: "Send \"November news\""
          assert_select "#users > li", count: 3
          assert_select "#user_#{@member.id}" do
            assert_select "input[type='checkbox'][checked][disabled]"
            assert_match(/Sent /, css_select("#user_#{@member.id} p").text)
          end
          assert_select "#user_#{@administrator.id}", text: /Queued/
          assert_select "#user_#{@candidate.id}" do
            assert_select "span", text: "Cora Candidate"
            assert_select "input[type='checkbox'][name='user_ids[]'][value='#{@candidate.id}'][data-select-all-target='child']"
          end
          assert_select "#user_#{@candidate.id}", text: /Not sent/
          assert_select "form[action='#{@path}'][data-controller='select-all'] input[data-select-all-target='parent']"
        end

        test "new filters users" do
          sign_in_as @administrator

          get "#{@path}/new", params: { filter: { query: "cora", sent: "false" } }

          assert_select "#users > li", count: 1
          assert_select "#user_#{@candidate.id}"
          assert_select "select[name='filter[sent]'] option[selected][value='false']"
          assert_select "select[name='filter[role]'] option[value='administrator']", text: "Administrator"
          assert_select "select[name='filter[per_page]'] option[value='50']", text: "50 per page"
        end

        test "new responds with not found for an unknown email" do
          sign_in_as @administrator

          get "/application/administration/emails/0/deliveries/new"

          assert_response :not_found
        end

        test "new redirects a member to the home page" do
          sign_in_as @member

          get "#{@path}/new"

          assert_redirected_to "/application/"
        end

        test "create queues the email for the selected users" do
          sign_in_as @administrator

          assert_enqueued_jobs 2, only: Moduler::EmailDeliveryJob do
            post @path, params: { user_ids: [ @candidate.id, @administrator.id, @member.id ] }
          end

          assert_redirected_to "#{@path}/new"
          assert_equal "The email has been queued for 2 users", flash[:notice]
          assert @email.user_emails.exists?(user: @candidate)
        end

        test "create without selected users queues nothing" do
          sign_in_as @administrator

          assert_no_enqueued_jobs do
            post @path
          end

          assert_equal "The email has not been queued for anyone", flash[:notice]
        end

        test "create redirects a member to the home page" do
          sign_in_as @member

          assert_no_enqueued_jobs do
            post @path, params: { user_ids: [ @candidate.id ] }
          end

          assert_redirected_to "/application/"
        end

        test "the queued email is delivered and recorded" do
          sign_in_as @administrator

          perform_enqueued_jobs do
            post @path, params: { user_ids: [ @candidate.id ] }
          end

          assert @email.user_emails.find_by!(user: @candidate).sent?
          assert_equal [ "November news" ], @candidate.sent_emails.map(&:subject)
        end
      end
    end
  end
end
