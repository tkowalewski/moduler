require "test_helper"

module Moduler
  module Administration
    class RolePolicyTest < ActiveSupport::TestCase
      setup do
        @record = Moduler::Role
        @role = moduler_roles(:acme_owner)
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "allows an administrator on all actions" do
        policy = RolePolicy.new(@administrator, @record)

        assert policy.index?
        assert policy.new?
        assert policy.create?
      end

      test "allows an administrator to manage a role" do
        policy = RolePolicy.new(@administrator, @role)

        assert policy.edit?
        assert policy.update?
      end

      test "denies a member on all actions" do
        policy = RolePolicy.new(@member, @role)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies a guest on all actions" do
        policy = RolePolicy.new(nil, @role)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies destroying a role" do
        assert_not RolePolicy.new(@administrator, @role).destroy?
      end

      test "denies showing a role" do
        assert_not RolePolicy.new(@administrator, @role).show?
      end
    end
  end
end
