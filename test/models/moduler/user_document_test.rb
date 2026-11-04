require "test_helper"

module Moduler
  class UserDocumentTest < ActiveSupport::TestCase
    setup do
      @user = moduler_users(:administrator)
      @document = moduler_documents(:privacy_policy)
    end

    test "is valid with a user and a document" do
      user_document = Moduler::UserDocument.new(user: @user, document: @document)
      assert user_document.valid?, "Expected user document to be valid, got: #{user_document.errors.full_messages}"
    end

    test "is invalid without a user" do
      user_document = Moduler::UserDocument.new(document: @document)
      assert_not user_document.valid?
      assert user_document.errors[:user].any?
    end

    test "is invalid without a document" do
      user_document = Moduler::UserDocument.new(user: @user)
      assert_not user_document.valid?
      assert user_document.errors[:document].any?
    end

    test "is invalid when the user already has the document" do
      existing = moduler_user_documents(:default_privacy_policy)
      user_document = Moduler::UserDocument.new(user: existing.user, document: existing.document)
      assert_not user_document.valid?
      assert_includes user_document.errors[:user], "has already been taken"
    end

    test "allows the same document for different users" do
      user_document = Moduler::UserDocument.new(user: @user, document: @document)
      assert user_document.valid?
    end

    test "allows different documents for the same user" do
      document = Moduler::Document.new(name: "Data processing agreement", kind: "data_processing_agreement")
      document.file.attach(io: file_fixture("document.pdf").open, filename: "document.pdf", content_type: "application/pdf")
      document.save!

      user_document = Moduler::UserDocument.new(user: moduler_users(:default), document: document)
      assert user_document.valid?
    end

    test "the database rejects a duplicate user and document pair" do
      existing = moduler_user_documents(:default_privacy_policy)

      assert_raises(ActiveRecord::RecordNotUnique) do
        Moduler::UserDocument.new(user: existing.user, document: existing.document).save!(validate: false)
      end
    end

    test "stores the user and the document in the moduler foreign key columns" do
      user_document = Moduler::UserDocument.create!(user: @user, document: @document)

      assert_equal @user.id, user_document.moduler_user_id
      assert_equal @document.id, user_document.moduler_document_id
    end

    test "belongs to its user and document" do
      user_document = moduler_user_documents(:default_privacy_policy)
      assert_equal moduler_users(:default), user_document.user
      assert_equal moduler_documents(:privacy_policy), user_document.document
    end

    test "records when the document was accepted" do
      user_document = Moduler::UserDocument.create!(user: @user, document: @document)
      assert_not_nil user_document.created_at
    end
  end
end
