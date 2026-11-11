require "test_helper"

module Moduler
  class OrganizationTest < ActiveSupport::TestCase
    def build_organization(**attributes)
      Moduler::Organization.new(name: "Initech", **attributes)
    end

    test "is valid with all required attributes" do
      organization = build_organization
      assert organization.valid?, "Expected organization to be valid, got: #{organization.errors.full_messages}"
    end

    test "is invalid without name" do
      organization = build_organization(name: nil)
      assert_not organization.valid?
      assert_includes organization.errors[:name], "can't be blank"
    end

    test "is invalid with a blank name" do
      organization = build_organization(name: "")
      assert_not organization.valid?
      assert_includes organization.errors[:name], "can't be blank"
    end

    test "is invalid with a name already taken" do
      organization = build_organization(name: moduler_organizations(:acme).name)
      assert_not organization.valid?
      assert_includes organization.errors[:name], "has already been taken"
    end

    test "can be persisted with valid attributes" do
      assert_difference "Moduler::Organization.count", 1 do
        build_organization.save!
      end
    end

    test "generates a uuid primary key" do
      organization = build_organization
      organization.save!
      assert_match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/, organization.id)
    end

    test "database rejects a missing name" do
      assert_raises(ActiveRecord::NotNullViolation) do
        build_organization(name: nil).save!(validate: false)
      end
    end

    test "database rejects a duplicate name" do
      assert_raises(ActiveRecord::RecordNotUnique) do
        build_organization(name: moduler_organizations(:acme).name).save!(validate: false)
      end
    end
  end
end
