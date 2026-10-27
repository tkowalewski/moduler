require "test_helper"

module Moduler
  module Administration
    class ArticlePolicyTest < ActiveSupport::TestCase
      setup do
        @record = Moduler::Article
        @article = moduler_articles(:default)
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "allows an administrator on all actions" do
        policy = ArticlePolicy.new(@administrator, @record)

        assert policy.index?
        assert policy.new?
        assert policy.create?
      end

      test "allows an administrator to manage an article" do
        policy = ArticlePolicy.new(@administrator, @article)

        assert policy.edit?
        assert policy.update?
        assert policy.destroy?
      end

      test "denies a member on all actions" do
        policy = ArticlePolicy.new(@member, @article)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies a guest on all actions" do
        policy = ArticlePolicy.new(nil, @article)

        assert_not policy.index?
        assert_not policy.new?
        assert_not policy.create?
        assert_not policy.edit?
        assert_not policy.update?
        assert_not policy.destroy?
      end

      test "denies showing an article" do
        assert_not ArticlePolicy.new(@administrator, @article).show?
      end
    end
  end
end
