require "test_helper"

module Moduler
  class MembershipTest < ActiveSupport::TestCase
    setup do
      @organization = moduler_organizations(:acme)
      @user = Moduler::User.create!(email_address: "member@domain.tld", password: "password123")
    end

    def build_membership(**attributes)
      Moduler::Membership.new(user: @user, organization: @organization, role: moduler_roles(:acme_viewer), **attributes)
    end

    test "permission? checks the permissions of the role" do
      membership = build_membership

      assert membership.permission?("tasks.read")
      assert membership.permission?(:"tasks.read")
      assert_not membership.permission?("tasks.write")
    end

    test "is valid with all required attributes" do
      membership = build_membership
      assert membership.valid?, "Expected membership to be valid, got: #{membership.errors.full_messages}"
    end

    %i[ user organization role ].each do |association|
      test "is invalid without #{association}" do
        membership = build_membership(association => nil)
        assert_not membership.valid?
        assert_includes membership.errors[association], "must exist"
      end
    end

    test "is invalid when the user already belongs to the organization" do
      membership = build_membership(user: moduler_users(:default))
      assert_not membership.valid?
      assert_includes membership.errors[:user], "has already been taken"
    end

    test "is valid when the user belongs to another organization" do
      membership = build_membership(user: moduler_users(:default), organization: moduler_organizations(:globex), role: moduler_roles(:globex_owner))
      assert membership.valid?, "Expected membership to be valid, got: #{membership.errors.full_messages}"
    end

    test "is invalid when the user is an administrator" do
      membership = build_membership(user: moduler_users(:administrator))
      assert_not membership.valid?
      assert_includes membership.errors[:user], "must have the member role"
    end

    test "is invalid with a role of another organization" do
      membership = build_membership(role: moduler_roles(:globex_owner))
      assert_not membership.valid?
      assert_includes membership.errors[:role], "is not included in the list"
    end

    test "can be persisted with valid attributes" do
      assert_difference "Moduler::Membership.count", 1 do
        build_membership.save!
      end
    end

    test "database rejects a duplicate user in the organization" do
      assert_raises(ActiveRecord::RecordNotUnique) do
        build_membership(user: moduler_users(:default)).save!(validate: false)
      end
    end

    test "search_by_query finds memberships by user email address" do
      build_membership.save!

      results = @organization.memberships.search_by_query("member@domain")
      assert_equal [ @user ], results.map(&:user)
    end

    test "search_by_query returns nothing for an unrelated query" do
      assert_empty Moduler::Membership.search_by_query("zzzzzz")
    end
  end
end
