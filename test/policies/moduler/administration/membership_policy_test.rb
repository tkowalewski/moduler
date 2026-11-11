require "test_helper"

module Moduler
  module Administration
    class MembershipPolicyTest < ActiveSupport::TestCase
      setup do
        @record = Moduler::Membership
        @membership = moduler_memberships(:default_acme)
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "allows an administrator on all actions" do
        policy = MembershipPolicy.new(@administrator, @record)

        assert policy.index?
        assert policy.new?
        assert policy.create?
      end

      test "allows an administrator to manage a membership" do
        policy = MembershipPolicy.new(@administrator, @membership)

        assert policy.edit?
        assert policy.update?
        assert policy.destroy?
      end

      test "denies a member on all actions" do
        policy = MembershipPolicy.new(@member, @membership)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies a guest on all actions" do
        policy = MembershipPolicy.new(nil, @membership)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies showing a membership" do
        assert_not MembershipPolicy.new(@administrator, @membership).show?
      end
    end
  end
end
