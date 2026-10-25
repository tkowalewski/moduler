require "test_helper"

module Moduler
  module Administration
    class UserPolicyTest < ActiveSupport::TestCase
      setup do
        @record = Moduler::User
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "allows an administrator on all actions" do
        policy = UserPolicy.new(@administrator, @record)

        assert policy.index?
        assert policy.new?
        assert policy.create?
        assert policy.edit?
        assert policy.update?
      end

      test "denies a member on all actions" do
        policy = UserPolicy.new(@member, @record)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
      end

      test "denies a guest on all actions" do
        policy = UserPolicy.new(nil, @record)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
      end
    end
  end
end
