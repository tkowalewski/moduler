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

    test "resources returns the configured resources with their permissions" do
      assert_equal [
        Moduler::Configuration::Resource.new(name: "reports", permission: nil),
        Moduler::Configuration::Resource.new(name: "projects", permission: "tasks.write")
      ], Moduler.configuration.resources
    end

    test "resources accepts string keys" do
      configuration = build_configuration(permissions: [ "tasks.read" ], resources: [ { "name" => "tasks", "permission" => "tasks.read" } ])

      assert_equal [ Moduler::Configuration::Resource.new(name: "tasks", permission: "tasks.read") ], configuration.resources
    end

    test "resources returns an empty array when none are defined" do
      assert_equal [], build_configuration.resources
    end

    test "resources raises for a permission that is not configured" do
      configuration = build_configuration(permissions: [ "tasks.read" ], resources: [ { name: "tasks", permission: "tasks.write" } ])

      error = assert_raises(ArgumentError) { configuration.resources }
      assert_match "tasks.write", error.message
    end

    test "resources raises for a resource without a name" do
      configuration = build_configuration(resources: [ { permission: "tasks.read" } ])

      assert_raises(ArgumentError) { configuration.resources }
    end

    test "administration_resources returns the names of the administration resources" do
      assert_equal %w[ tasks ], Moduler.configuration.administration_resources
      assert_equal %w[ tasks ], build_configuration(administration: { resources: [ { name: "tasks" } ] }).administration_resources
      assert_equal [], build_configuration.administration_resources
    end

    private

    def build_configuration(values = {})
      Moduler::Configuration.allocate.tap do |configuration|
        configuration.instance_variable_set(:@configuration, values)
      end
    end
  end
end
