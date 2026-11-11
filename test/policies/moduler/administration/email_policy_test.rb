require "test_helper"

module Moduler
  module Administration
    class EmailPolicyTest < ActiveSupport::TestCase
      setup do
        @email = moduler_emails(:newsletter)
        @member = moduler_users(:default)
        @administrator = moduler_users(:administrator)
      end

      test "allows an administrator on all actions" do
        policy = EmailPolicy.new(@administrator, @email)

        %i[ index? new? create? edit? update? destroy? deliver? ].each { |action| assert policy.public_send(action), action }
      end

      test "denies a member and a guest on all actions" do
        [ @member, nil ].each do |user|
          policy = EmailPolicy.new(user, @email)

          %i[ index? new? create? edit? update? destroy? deliver? ].each { |action| assert_not policy.public_send(action), action }
        end
      end

      test "denies showing an email" do
        assert_not EmailPolicy.new(@administrator, @email).show?
      end
    end
  end
end
