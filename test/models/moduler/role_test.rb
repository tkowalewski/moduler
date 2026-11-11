require "test_helper"

module Moduler
  class RoleTest < ActiveSupport::TestCase
    def build_role(**attributes)
      Moduler::Role.new(organization: moduler_organizations(:acme), name: "Editor", permissions: %w[ tasks.read tasks.write ], **attributes)
    end

    test "is valid with all required attributes" do
      role = build_role
      assert role.valid?, "Expected role to be valid, got: #{role.errors.full_messages}"
    end

    test "is valid without permissions" do
      role = build_role(permissions: [])
      assert role.valid?, "Expected role to be valid, got: #{role.errors.full_messages}"
    end

    test "is invalid without an organization" do
      role = build_role(organization: nil)
      assert_not role.valid?
      assert_includes role.errors[:organization], "must exist"
    end

    test "is invalid without name" do
      role = build_role(name: nil)
      assert_not role.valid?
      assert_includes role.errors[:name], "can't be blank"
    end

    test "is invalid with a blank name" do
      role = build_role(name: "")
      assert_not role.valid?
      assert_includes role.errors[:name], "can't be blank"
    end

    test "is invalid with a name already taken in the same organization" do
      role = build_role(name: moduler_roles(:acme_owner).name)
      assert_not role.valid?
      assert_includes role.errors[:name], "has already been taken"
    end

    test "is valid with a name taken in another organization" do
      role = build_role(organization: moduler_organizations(:globex), name: moduler_roles(:acme_viewer).name)
      assert role.valid?, "Expected role to be valid, got: #{role.errors.full_messages}"
    end

    test "is invalid with a permission not defined in the configuration" do
      role = build_role(permissions: %w[ tasks.read tasks.delete ])
      assert_not role.valid?
      assert_includes role.errors[:permissions], "is not included in the list"
    end

    test "removes blank and duplicated permissions" do
      role = build_role(permissions: [ "", "tasks.read", "tasks.read", nil, :"tasks.write" ])
      assert_equal %w[ tasks.read tasks.write ], role.permissions
    end

    test "defaults permissions to an empty array" do
      assert_equal [], Moduler::Role.new.permissions
    end

    test "permission? checks whether the role grants a permission" do
      role = moduler_roles(:acme_viewer)
      assert role.permission?("tasks.read")
      assert role.permission?(:"tasks.read")
      assert_not role.permission?("tasks.write")
    end

    test "can be persisted with valid attributes" do
      assert_difference "Moduler::Role.count", 1 do
        build_role.save!
      end
    end

    test "persists permissions" do
      role = build_role
      role.save!
      assert_equal %w[ tasks.read tasks.write ], role.reload.permissions
    end

    test "database rejects a duplicate name in the same organization" do
      assert_raises(ActiveRecord::RecordNotUnique) do
        build_role(name: moduler_roles(:acme_owner).name).save!(validate: false)
      end
    end

    test "search_by_query finds roles by name" do
      results = moduler_organizations(:acme).roles.search_by_query("Viewer")
      assert_includes results, moduler_roles(:acme_viewer)
      assert_not_includes results, moduler_roles(:acme_owner)
    end

    test "memberships returns the memberships with the role" do
      assert_includes moduler_roles(:acme_owner).memberships, moduler_memberships(:default_acme)
      assert_empty moduler_roles(:acme_viewer).memberships
    end

    test "cannot be destroyed while it has memberships" do
      role = moduler_roles(:acme_owner)

      assert_not role.destroy
      assert role.persisted?
      assert role.errors[:base].any?
    end
  end
end
