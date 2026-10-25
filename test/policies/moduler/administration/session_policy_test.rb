require "test_helper"

module Moduler
  module Administration
    class SessionPolicyTest < ActiveSupport::TestCase
      setup do
        @record = Moduler::Session
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "allows an administrator on all actions" do
        policy = SessionPolicy.new(@administrator, @record)

        assert policy.index?
        assert policy.destroy?
      end

      test "denies a member on all actions" do
        policy = SessionPolicy.new(@member, @record)

        assert_not policy.index?
        assert_not policy.destroy?
      end

      test "denies a guest on all actions" do
        policy = SessionPolicy.new(nil, @record)

        assert_not policy.index?
        assert_not policy.destroy?
      end
    end
  end
end
