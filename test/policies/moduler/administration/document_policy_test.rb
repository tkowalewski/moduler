require "test_helper"

module Moduler
  module Administration
    class DocumentPolicyTest < ActiveSupport::TestCase
      setup do
        @record = Moduler::Document
        @document = moduler_documents(:privacy_policy)
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "allows an administrator on all actions" do
        policy = DocumentPolicy.new(@administrator, @record)

        assert policy.index?
        assert policy.new?
        assert policy.create?
      end

      test "allows an administrator to manage a document" do
        policy = DocumentPolicy.new(@administrator, @document)

        assert policy.edit?
        assert policy.update?
      end

      test "denies a member on all actions" do
        policy = DocumentPolicy.new(@member, @document)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies a guest on all actions" do
        policy = DocumentPolicy.new(nil, @document)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies destroying a document" do
        assert_not DocumentPolicy.new(@administrator, @document).destroy?
      end

      test "denies showing a document" do
        assert_not DocumentPolicy.new(@administrator, @document).show?
      end
    end
  end
end
