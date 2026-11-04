require "test_helper"

module Moduler
  class DocumentAcceptanceTest < ActiveSupport::TestCase
    setup do
      @user = moduler_users(:administrator)
      @privacy_policy = moduler_documents(:privacy_policy)
      @terms = moduler_documents(:terms_and_conditions)
    end

    def acceptance(*documents, user: @user)
      DocumentAcceptance.new(user, documents.map(&:id))
    end

    test "pending_documents returns the documents the user has not accepted, oldest first" do
      @terms.update_column(:created_at, 1.day.ago)

      assert_equal [ @terms, @privacy_policy ], acceptance.pending_documents
    end

    test "accepted? tells whether a document is among the accepted ids" do
      document_acceptance = acceptance(@privacy_policy)

      assert document_acceptance.accepted?(@privacy_policy)
      assert_not document_acceptance.accepted?(@terms)
    end

    test "normalizes the document ids" do
      document_acceptance = DocumentAcceptance.new(@user, [ @privacy_policy.id.to_s, "", nil ])

      assert_equal [ @privacy_policy.id ], document_acceptance.document_ids
    end

    test "accepts no ids by default" do
      assert_empty DocumentAcceptance.new(@user).document_ids
      assert_empty DocumentAcceptance.new(@user, nil).document_ids
    end

    test "call accepts all pending documents when every one is accepted" do
      document_acceptance = acceptance(@privacy_policy, @terms)

      assert_difference "Moduler::UserDocument.count", 2 do
        assert document_acceptance.call
      end

      assert_empty @user.pending_documents
      assert @user.user_documents.all? { |user_document| user_document.created_at.present? }
    end

    test "call accepts nothing when a pending document is missing" do
      document_acceptance = acceptance(@privacy_policy)

      assert_no_difference "Moduler::UserDocument.count" do
        assert_not document_acceptance.call
      end

      assert_equal [ "Accept all documents to continue." ], document_acceptance.errors.full_messages
    end

    test "call accepts nothing when no document is accepted" do
      assert_no_difference "Moduler::UserDocument.count" do
        assert_not acceptance.call
      end
    end

    test "is valid only when every pending document is accepted" do
      assert acceptance(@privacy_policy, @terms).valid?
      assert_not acceptance(@terms).valid?
    end

    test "call ignores unknown and already accepted document ids" do
      Moduler::UserDocument.create!(user: @user, document: @privacy_policy)

      assert_difference "Moduler::UserDocument.count", 1 do
        assert DocumentAcceptance.new(@user, [ @privacy_policy.id, @terms.id, 0 ]).call
      end
    end

    test "call succeeds without changes when nothing is pending" do
      assert_no_difference "Moduler::UserDocument.count" do
        assert acceptance(user: moduler_users(:default)).call
      end
    end

    test "call does not accept documents for other users" do
      assert_no_difference -> { moduler_users(:default).user_documents.count } do
        acceptance(@privacy_policy, @terms).call
      end
    end

    test "call skips a document accepted in the meantime" do
      document_acceptance = acceptance(@privacy_policy, @terms)
      document_acceptance.pending_documents
      Moduler::UserDocument.create!(user: @user, document: @privacy_policy)

      assert_difference "Moduler::UserDocument.count", 1 do
        assert document_acceptance.call
      end
    end
  end
end
