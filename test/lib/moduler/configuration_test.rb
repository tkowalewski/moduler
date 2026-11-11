require "test_helper"

module Moduler
  class ConfigurationTest < ActiveSupport::TestCase
    test "permissions returns the permissions defined in the configuration" do
      assert_equal %w[ tasks.read tasks.write members.manage ], Moduler.configuration.permissions
    end

    test "permissions returns an empty array when none are defined" do
      configuration = Moduler::Configuration.allocate
      configuration.instance_variable_set(:@configuration, {})

      assert_equal [], configuration.permissions
    end
  end
end
