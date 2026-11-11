require "test_helper"

module Moduler
  module Administration
    class OrganizationPolicyTest < ActiveSupport::TestCase
      setup do
        @record = Moduler::Organization
        @organization = moduler_organizations(:acme)
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "allows an administrator on all actions" do
        policy = OrganizationPolicy.new(@administrator, @record)

        assert policy.index?
        assert policy.new?
        assert policy.create?
      end

      test "allows an administrator to manage an organization" do
        policy = OrganizationPolicy.new(@administrator, @organization)

        assert policy.edit?
        assert policy.update?
      end

      test "denies a member on all actions" do
        policy = OrganizationPolicy.new(@member, @organization)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies a guest on all actions" do
        policy = OrganizationPolicy.new(nil, @organization)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies destroying an organization" do
        assert_not OrganizationPolicy.new(@administrator, @organization).destroy?
      end

      test "denies showing an organization" do
        assert_not OrganizationPolicy.new(@administrator, @organization).show?
      end
    end
  end
end
