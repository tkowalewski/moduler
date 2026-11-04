require "test_helper"

module Moduler
  class DocumentTest < ActiveSupport::TestCase
    def build_document(file: true, **attributes)
      Moduler::Document.new(name: "Privacy policy 2026", kind: "privacy_policy", **attributes).tap do |document|
        document.file.attach(io: file_fixture("document.pdf").open, filename: "document.pdf", content_type: "application/pdf") if file
      end
    end

    test "is valid with all required attributes" do
      document = build_document
      assert document.valid?, "Expected document to be valid, got: #{document.errors.full_messages}"
    end

    %i[ name kind ].each do |attribute|
      test "is invalid without #{attribute}" do
        document = build_document(attribute => nil)
        assert_not document.valid?
        assert_includes document.errors[attribute], "can't be blank"
      end

      test "is invalid with a blank #{attribute}" do
        document = build_document(attribute => "")
        assert_not document.valid?
        assert_includes document.errors[attribute], "can't be blank"
      end
    end

    test "defines the allowed kinds" do
      assert_equal %w[ privacy_policy terms_and_conditions data_processing_agreement ], Moduler::Document::KINDS
      assert Moduler::Document::KINDS.frozen?
    end

    Moduler::Document::KINDS.each do |kind|
      test "is valid with the #{kind} kind" do
        document = build_document(kind: kind)
        assert document.valid?, "Expected kind '#{kind}' to be valid, got: #{document.errors.full_messages}"
      end
    end

    test "is invalid with an unknown kind" do
      document = build_document(kind: "cookie_policy")
      assert_not document.valid?
      assert_includes document.errors[:kind], "is not included in the list"
    end

    test "is invalid without a file" do
      document = build_document(file: false)
      assert_not document.valid?
      assert document.errors[:file].any?
    end

    test "is invalid with a file of a disallowed content type" do
      document = build_document(file: false)
      document.file.attach(io: file_fixture("document.txt").open, filename: "document.txt", content_type: "text/plain")
      assert_not document.valid?
      assert document.errors[:file].any?
    end

    test "is invalid with a file of 10 megabytes or more" do
      document = build_document(file: false)
      pdf = file_fixture("document.pdf").binread
      document.file.attach(io: StringIO.new(pdf + "\x00".b * (10.megabytes - pdf.bytesize)), filename: "large.pdf", content_type: "application/pdf")
      assert_not document.valid?
      assert document.errors[:file].any?
    end

    test "can be persisted with valid attributes" do
      assert_difference "Moduler::Document.count", 1 do
        build_document.save!
      end
    end

    test "persists the attached file" do
      document = build_document
      document.save!

      assert document.reload.file.attached?
      assert_equal "document.pdf", document.file.filename.to_s
      assert_equal "application/pdf", document.file.content_type
    end

    test "user_documents returns the acceptances of the document" do
      document = moduler_documents(:privacy_policy)
      assert_includes document.user_documents, moduler_user_documents(:default_privacy_policy)
      assert_not_includes document.user_documents, moduler_user_documents(:default_terms_and_conditions)
    end

    test "destroying the document deletes its user documents" do
      document = moduler_documents(:privacy_policy)
      user_document_id = moduler_user_documents(:default_privacy_policy).id

      assert_difference "Moduler::UserDocument.count", -1 do
        document.destroy!
      end
      assert_not Moduler::UserDocument.exists?(user_document_id)
    end

    test "destroying the document keeps its users" do
      document = moduler_documents(:privacy_policy)

      assert_no_difference "Moduler::User.count" do
        document.destroy!
      end
    end

    test "search_by_query finds documents by name" do
      results = Moduler::Document.search_by_query("Privacy")
      assert_includes results, moduler_documents(:privacy_policy)
      assert_not_includes results, moduler_documents(:terms_and_conditions)
    end

    test "search_by_query finds documents by kind" do
      results = Moduler::Document.search_by_query("terms_and_conditions")
      assert_includes results, moduler_documents(:terms_and_conditions)
    end

    test "search_by_query returns nothing for an unrelated query" do
      assert_empty Moduler::Document.search_by_query("zzzzzz")
    end
  end
end
