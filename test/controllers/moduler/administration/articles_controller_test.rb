require "test_helper"

module Moduler
  module Administration
    class ArticlesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
        @article = moduler_articles(:default)
      end

      def article_params(**overrides)
        {
          path: "new-article",
          title: "New article",
          description: "A brand new article.",
          keywords: "new, article",
          content: "# Hello"
        }.merge(overrides)
      end

      test "index redirects a guest to the sign in page" do
        get "/application/administration/articles"

        assert_redirected_to "/application/session/new"
      end

      test "index redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/articles"

        assert_redirected_to "/application/"
      end

      test "index lists articles for an administrator" do
        sign_in_as @administrator

        get "/application/administration/articles"

        assert_response :success
        assert_select "#articles > li", count: Moduler::Article.count
        assert_select "#articles", text: /#{@article.title}/
        assert_select "a[href='/application/administration/articles/new']"
        assert_select "a[href='/application/administration/articles/#{@article.id}/edit']"
      end

      test "index filters articles by query" do
        sign_in_as @administrator
        Moduler::Article.create!(article_params(path: "other", title: "Deployment", keywords: "deploy"))

        get "/application/administration/articles", params: { filter: { query: "started" } }

        assert_response :success
        assert_select "#articles > li", count: 1
        assert_select "#articles", text: /#{@article.title}/
      end

      test "index renders an empty state when no articles match the query" do
        sign_in_as @administrator

        get "/application/administration/articles", params: { filter: { query: "zzzzzz" } }

        assert_response :success
        assert_select "#articles", count: 0
        assert_match "No articles found", response.body
      end

      test "index paginates articles" do
        sign_in_as @administrator
        12.times { |i| Moduler::Article.create!(article_params(path: "article-#{i}")) }

        get "/application/administration/articles"

        assert_select "#articles > li", count: 10
        assert_select "nav[aria-label='Pagination'] a[rel='next']"

        get "/application/administration/articles", params: { page: 2 }

        assert_select "#articles > li", count: Moduler::Article.count - 10
      end

      test "new redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/articles/new"

        assert_redirected_to "/application/"
      end

      test "new renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/articles/new"

        assert_response :success
        assert_select "form[action='/application/administration/articles']" do
          assert_select "input[name='article[title]']"
          assert_select "input[name='article[path]']"
          assert_select "textarea[name='article[description]']"
          assert_select "input[name='article[keywords]']"
          assert_select "textarea[name='article[content]']"
        end
      end

      test "create creates an article and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { Moduler::Article.count }, 1 do
          post "/application/administration/articles", params: { article: article_params }
        end

        assert_redirected_to "/application/administration/articles"
        assert_equal "Article has been created", flash[:notice]
        article = Moduler::Article.find_by!(path: "new-article")
        assert_equal "New article", article.title
        assert_equal "# Hello", article.content
      end

      test "create attaches uploaded images" do
        sign_in_as @administrator

        post "/application/administration/articles", params: {
          article: article_params(images: [ fixture_file_upload("image.png", "image/png") ])
        }

        assert_redirected_to "/application/administration/articles"
        assert_equal 1, Moduler::Article.find_by!(path: "new-article").images.count
      end

      test "create re-renders the form when the article is invalid" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Article.count } do
          post "/application/administration/articles", params: {
            article: article_params(path: @article.path, title: "")
          }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/articles']"
      end

      test "create rejects images with a disallowed content type" do
        sign_in_as @administrator

        assert_no_difference -> { Moduler::Article.count } do
          post "/application/administration/articles", params: {
            article: article_params(images: [ fixture_file_upload("document.txt", "text/plain") ])
          }
        end

        assert_response :unprocessable_entity
      end

      test "update re-renders the form when an image has a disallowed content type" do
        sign_in_as @administrator

        patch "/application/administration/articles/#{@article.id}", params: {
          article: { images: [ fixture_file_upload("document.txt", "text/plain") ] }
        }

        assert_response :unprocessable_entity
        assert_equal 0, @article.reload.images.count
      end

      test "create responds with bad request when article params are missing" do
        sign_in_as @administrator

        post "/application/administration/articles"

        assert_response :bad_request
      end

      test "create redirects a member to the home page" do
        sign_in_as @member

        assert_no_difference -> { Moduler::Article.count } do
          post "/application/administration/articles", params: { article: article_params }
        end

        assert_redirected_to "/application/"
      end

      test "edit renders the form for an administrator" do
        sign_in_as @administrator

        get "/application/administration/articles/#{@article.id}/edit"

        assert_response :success
        assert_select "form[action='/application/administration/articles/#{@article.id}']" do
          assert_select "input[name='_method'][value='patch']"
          assert_select "input[name='article[title]'][value='#{@article.title}']"
          assert_select "input[name='article[path]'][value='#{@article.path}']"
          assert_select "textarea[name='article[content]']", text: @article.content
        end
      end

      test "edit responds with not found for an unknown article" do
        sign_in_as @administrator

        get "/application/administration/articles/#{SecureRandom.uuid}/edit"

        assert_response :not_found
      end

      test "edit redirects a member to the home page" do
        sign_in_as @member

        get "/application/administration/articles/#{@article.id}/edit"

        assert_redirected_to "/application/"
      end

      test "update changes the article and redirects to the list" do
        sign_in_as @administrator

        patch "/application/administration/articles/#{@article.id}", params: {
          article: { title: "Changed title", path: "changed-path" }
        }

        assert_redirected_to "/application/administration/articles"
        assert_equal "Article has been updated", flash[:notice]
        @article.reload
        assert_equal "Changed title", @article.title
        assert_equal "changed-path", @article.path
      end

      test "update re-renders the form when the article is invalid" do
        sign_in_as @administrator

        assert_no_changes -> { @article.reload.path } do
          patch "/application/administration/articles/#{@article.id}", params: {
            article: { path: "Invalid Path!" }
          }
        end

        assert_response :unprocessable_entity
        assert_select "form[action='/application/administration/articles/#{@article.id}']"
      end

      test "update redirects a member to the home page" do
        sign_in_as @member

        assert_no_changes -> { @article.reload.title } do
          patch "/application/administration/articles/#{@article.id}", params: { article: { title: "Hacked" } }
        end

        assert_redirected_to "/application/"
      end

      test "destroy deletes the article and redirects to the list" do
        sign_in_as @administrator

        assert_difference -> { Moduler::Article.count }, -1 do
          delete "/application/administration/articles/#{@article.id}"
        end

        assert_redirected_to "/application/administration/articles"
        assert_response :see_other
        assert_equal "Article has been deleted", flash[:notice]
      end

      test "destroy responds with not found for an unknown article" do
        sign_in_as @administrator

        delete "/application/administration/articles/#{SecureRandom.uuid}"

        assert_response :not_found
      end

      test "destroy redirects a member to the home page" do
        sign_in_as @member

        assert_no_difference -> { Moduler::Article.count } do
          delete "/application/administration/articles/#{@article.id}"
        end

        assert_redirected_to "/application/"
      end
    end
  end
end
