require "test_helper"

class EmailDeliveryFilterTest < ActiveSupport::TestCase
  setup do
    @email = moduler_emails(:newsletter)
    @scope = Moduler::User
      .joins(Moduler::User.sanitize_sql_array([
        "LEFT JOIN moduler_user_emails ON moduler_user_emails.moduler_user_id = moduler_users.id AND moduler_user_emails.moduler_email_id = ?", @email.id
      ]))
      .order(:email_address)
  end

  def results(parameters)
    EmailDeliveryFilter.new(@scope, parameters).call.last.to_a
  end

  test "returns all users without parameters" do
    assert_equal Moduler::User.count, results({}).size
  end

  test "filters by email address or name, escaping wildcards" do
    moduler_users(:administrator).update!(name: "Ada Admin")

    assert_equal [ moduler_users(:default) ], results(query: "test@")
    assert_equal [ moduler_users(:administrator) ], results(query: "ada")
    assert_empty results(query: "%")
  end

  test "filters by role and ignores an unknown role" do
    assert_equal [ moduler_users(:administrator) ], results(role: "administrator")
    assert_equal Moduler::User.count, results(role: "owner").size
  end

  test "filters by whether the email has been delivered, counting queued as not sent" do
    queued = Moduler::User.create!(email_address: "queued@domain.tld", password: "password123")
    Moduler::UserEmail.create!(user: queued, email: @email)

    assert_equal [ moduler_users(:default) ], results(sent: "true")
    assert_equal [ moduler_users(:administrator), queued ], results(sent: "false")
  end

  test "paginates by an allowed number per page" do
    30.times { |i| Moduler::User.create!(email_address: "user#{i}@domain.tld", password: "password123") }

    assert_equal 25, results({}).size
    assert_equal 32, results(per_page: 50).size
    assert_equal 25, results(per_page: 1000).size
  end
end
