module Moduler
  class Configuration
    extend Forwardable

    # A sidebar resource from config/moduler.yml: its +name+ (for the route, the
    # translation and the active state) and the +permission+ a member needs to
    # see it, or +nil+ when every member of the organization sees it.
    Resource = Data.define(:name, :permission)

    def_delegator :@configuration, :[]
    def_delegator :@configuration, :dig

    def initialize
      @configuration = Rails.application.config_for(:moduler)
    end

    # Permissions that can be granted to organization roles, defined under
    # `permissions` in config/moduler.yml.
    def permissions
      Array(dig(:permissions)).map(&:to_s)
    end

    # Resources linked from the application sidebar, defined under `resources`
    # in config/moduler.yml either by name or with the permission needed to see
    # them:
    #
    #   resources:
    #     - reports
    #     - name: tasks
    #       permission: tasks.read
    def resources
      Array(dig(:resources)).map { |resource| build_resource(resource) }
    end

    # Resources linked from the administration sidebar, defined by name under
    # `administration.resources` in config/moduler.yml. Administrators see all of them.
    def administration_resources
      Array(dig(:administration, :resources)).map { |resource| build_resource(resource).name }
    end

    private

    def build_resource(resource)
      return Resource.new(name: resource.to_s, permission: nil) unless resource.is_a?(Hash)

      resource = resource.to_h.symbolize_keys
      name = resource[:name].to_s
      permission = resource[:permission]&.to_s

      raise ArgumentError, "Resource in config/moduler.yml needs a name: #{resource.inspect}" if name.blank?
      if permission && !permissions.include?(permission)
        raise ArgumentError, "Permission #{permission.inspect} of the #{name} resource is not defined under permissions in config/moduler.yml"
      end

      Resource.new(name:, permission:)
    end
  end
end
