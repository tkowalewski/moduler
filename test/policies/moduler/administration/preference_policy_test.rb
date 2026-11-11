require "test_helper"

module Moduler
  module Administration
    class PreferencePolicyTest < ActiveSupport::TestCase
      setup do
        @record = Moduler::Preference
        @preference = moduler_preferences(:waitlist)
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "allows an administrator on all actions" do
        policy = PreferencePolicy.new(@administrator, @record)

        assert policy.index?
        assert policy.new?
        assert policy.create?
      end

      test "allows an administrator to manage a preference" do
        policy = PreferencePolicy.new(@administrator, @preference)

        assert policy.edit?
        assert policy.update?
        assert policy.destroy?
      end

      test "denies a member on all actions" do
        policy = PreferencePolicy.new(@member, @preference)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies a guest on all actions" do
        policy = PreferencePolicy.new(nil, @preference)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies showing a preference" do
        assert_not PreferencePolicy.new(@administrator, @preference).show?
      end
    end
  end
end
