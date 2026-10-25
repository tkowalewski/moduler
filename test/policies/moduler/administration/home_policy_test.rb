require "test_helper"

module Moduler
  module Administration
    class HomePolicyTest < ActiveSupport::TestCase
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "index? allows an administrator" do
        assert HomePolicy.new(@administrator, :home).index?
      end

      test "index? denies a member" do
        assert_not HomePolicy.new(@member, :home).index?
      end

      test "index? denies a guest" do
        assert_not HomePolicy.new(nil, :home).index?
      end
    end
  end
end
