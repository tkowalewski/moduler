require "test_helper"

class ArticlesAliasTest < ActionDispatch::IntegrationTest
  test "articles alias redirects permanently to the articles list" do
    get "/articles"

    assert_response :moved_permanently
    assert_redirected_to "/application/articles"
  end

  test "article alias redirects permanently to the article" do
    article = moduler_articles(:default)

    get "/articles/#{article.path}"

    assert_response :moved_permanently
    assert_redirected_to "/application/articles/#{article.path}"
  end

  test "article alias redirect leads to the article" do
    article = moduler_articles(:default)

    get "/articles/#{article.path}"
    follow_redirect!

    assert_response :success
    assert_select "article h1", text: article.title
  end
end
