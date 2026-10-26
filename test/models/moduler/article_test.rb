require "test_helper"

module Moduler
  class ArticleTest < ActiveSupport::TestCase
    def build_article(**attributes)
      Moduler::Article.new(
        path: "new-article",
        title: "New article",
        description: "Description of the new article.",
        keywords: "new, article",
        content: "Content of the new article.",
        **attributes
      )
    end

    test "is valid with all required attributes" do
      article = build_article
      assert article.valid?, "Expected article to be valid, got: #{article.errors.full_messages}"
    end

    %i[ path title description keywords content ].each do |attribute|
      test "is invalid without #{attribute}" do
        article = build_article(attribute => nil)
        assert_not article.valid?
        assert_includes article.errors[attribute], "can't be blank"
      end

      test "is invalid with a blank #{attribute}" do
        article = build_article(attribute => "")
        assert_not article.valid?
        assert_includes article.errors[attribute], "can't be blank"
      end
    end

    test "is invalid with a duplicate path" do
      existing = moduler_articles(:default)
      article = build_article(path: existing.path)
      assert_not article.valid?
      assert_includes article.errors[:path], "has already been taken"
    end

    test "can update other attributes without triggering the uniqueness error on itself" do
      article = moduler_articles(:default)
      article.title = "Updated title"
      assert article.valid?
    end

    test "is valid with well-formed paths" do
      valid_paths = [
        "article",
        "my-article",
        "article-2",
        "2026",
        "a-b-c-d"
      ]

      valid_paths.each do |good_path|
        article = build_article(path: good_path)
        assert article.valid?, "Expected '#{good_path}' to be valid, got: #{article.errors.full_messages}"
      end
    end

    test "is invalid with a malformed path" do
      invalid_paths = [
        "My-Article",
        "my_article",
        "my article",
        "-article",
        "article-",
        "my--article",
        "my/article",
        "/article",
        "artykuł",
        "article\nother"
      ]

      invalid_paths.each do |bad_path|
        article = build_article(path: bad_path)
        assert_not article.valid?, "Expected '#{bad_path}' to be invalid"
        assert_includes article.errors[:path], "is invalid"
      end
    end

    test "is valid without images" do
      article = build_article
      assert_empty article.images
      assert article.valid?
    end

    test "is valid with a png image" do
      article = build_article
      article.images.attach(io: file_fixture("image.png").open, filename: "image.png", content_type: "image/png")
      assert article.valid?, "Expected article to be valid, got: #{article.errors.full_messages}"
    end

    test "is invalid with an image of a disallowed content type" do
      article = build_article
      article.images.attach(io: file_fixture("document.txt").open, filename: "document.txt", content_type: "text/plain")
      assert_not article.valid?
      assert article.errors[:images].any?
    end

    test "is invalid with an image of 10 megabytes or more" do
      article = build_article
      png = file_fixture("image.png").binread
      article.images.attach(io: StringIO.new(png + "\x00".b * (10.megabytes - png.bytesize)), filename: "large.png", content_type: "image/png")
      assert_not article.valid?
      assert article.errors[:images].any?
    end

    test "can have many images attached" do
      article = build_article
      2.times do |index|
        article.images.attach(io: file_fixture("image.png").open, filename: "image-#{index}.png", content_type: "image/png")
      end
      article.save!

      assert_equal 2, article.reload.images.count
    end

    test "can be persisted with valid attributes" do
      assert_difference "Moduler::Article.count", 1 do
        build_article.save!
      end
    end

    test "cannot be persisted with a duplicate path" do
      existing = moduler_articles(:default)

      assert_no_difference "Moduler::Article.count" do
        build_article(path: existing.path).save
      end
    end

    test "database enforces path uniqueness" do
      existing = moduler_articles(:default)
      article = build_article(path: existing.path)

      assert_raises(ActiveRecord::RecordNotUnique) do
        article.save!(validate: false)
      end
    end

    test "search_by_query finds articles by title" do
      assert_includes Moduler::Article.search_by_query("Getting"), moduler_articles(:default)
    end

    test "search_by_query finds articles by keywords" do
      assert_includes Moduler::Article.search_by_query("guide"), moduler_articles(:default)
    end

    test "search_by_query does not search in content" do
      article = build_article(content: "unicorn")
      article.save!

      assert_not_includes Moduler::Article.search_by_query("unicorn"), article
    end

    test "search_by_query does not return unrelated articles" do
      assert_not_includes Moduler::Article.search_by_query("zzzzzz"), moduler_articles(:default)
    end
  end
end
