require "test_helper"

module Moduler
  class ArticlesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @article = moduler_articles(:default)
    end

    test "index succeeds without signing in" do
      get "/application/articles"

      assert_response :success
    end

    test "index succeeds for a signed in user" do
      sign_in_as moduler_users(:default)

      get "/application/articles"

      assert_response :success
    end

    test "index lists articles with links to them" do
      get "/application/articles"

      assert_select "#articles > li", count: Moduler::Article.count
      assert_select "#articles a[href='/application/articles/#{@article.path}']", text: @article.title
      assert_select "#articles", text: /#{@article.description}/
    end

    test "index lists the newest articles first" do
      newer = Moduler::Article.create!(path: "newer", title: "Newer article", description: "Newer.", keywords: "newer", content: "Newer.")

      get "/application/articles"

      assert_select "#articles > li:first-child##{ActionView::RecordIdentifier.dom_id(newer)}"
    end

    test "index renders an empty message without articles" do
      Moduler::Article.delete_all

      get "/application/articles"

      assert_select "#articles", count: 0
      assert_select "p", text: "No articles have been published yet."
    end

    test "show succeeds without signing in" do
      get "/application/articles/#{@article.path}"

      assert_response :success
    end

    test "show renders the article" do
      get "/application/articles/#{@article.path}"

      assert_select "article h1", text: @article.title
      assert_select "article header", text: /#{@article.description}/
      assert_select "article .prose", text: /#{@article.content}/
    end

    test "show renders markdown content as html" do
      @article.update!(content: "## Heading\n\n**bold**")

      get "/application/articles/#{@article.path}"

      assert_select "article .prose h2", text: "Heading"
      assert_select "article .prose strong", text: "bold"
    end

    test "show sanitizes scripts in content" do
      @article.update!(content: "<script>alert('xss')</script>")

      get "/application/articles/#{@article.path}"

      assert_select "article .prose script", count: 0
    end

    test "show renders description and keywords meta tags" do
      get "/application/articles/#{@article.path}"

      assert_select "meta[name='description'][content='#{@article.description}']"
      assert_select "meta[name='keywords'][content='#{@article.keywords}']"
    end

    test "show responds with not found for an unknown path" do
      get "/application/articles/unknown"

      assert_response :not_found
    end
  end
end
