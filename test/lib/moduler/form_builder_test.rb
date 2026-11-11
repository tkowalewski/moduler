require "test_helper"

module Moduler
  class FormBuilderTest < ActionView::TestCase
    setup do
      @membership = Moduler::Membership.new
    end

    def builder(object = @membership)
      Moduler::FormBuilder.new(:membership, object, self, {})
    end

    test "error? is false without errors" do
      assert_not builder.error?(:moduler_user_id)
    end

    test "error? is true for errors of the field" do
      @membership.errors.add(:moduler_user_id, "is invalid")

      assert builder.error?(:moduler_user_id)
    end

    test "error? is true for errors of the belongs_to association of a foreign key field" do
      @membership.errors.add(:user, "must exist")

      assert builder.error?(:moduler_user_id)
      assert_not builder.error?(:moduler_role_id)
    end

    test "error? is false without an object" do
      assert_not builder(nil).error?(:moduler_user_id)
    end

    test "error renders the first error of the field" do
      @membership.errors.add(:moduler_user_id, "is invalid")
      @membership.errors.add(:user, "must exist")

      assert_dom_equal %(<div class="error">is invalid</div>), builder.error(:moduler_user_id, class: "error")
    end

    test "error renders the error of the belongs_to association of a foreign key field" do
      @membership.errors.add(:user, "must exist")

      assert_dom_equal %(<div>must exist</div>), builder.error(:moduler_user_id)
    end

    test "error renders nothing without errors" do
      assert_nil builder.error(:moduler_user_id)
    end

    test "full_error renders the full message of the belongs_to association of a foreign key field" do
      @membership.errors.add(:user, "must exist")

      assert_dom_equal %(<div>User must exist</div>), builder.full_error(:moduler_user_id)
    end

    test "error? works for objects without associations" do
      filter = QueryFilter.new(Moduler::User, { query: "a" * 101 }).tap(&:valid?)

      assert Moduler::FormBuilder.new(:filter, filter, self, {}).error?(:query)
    end
  end
end
