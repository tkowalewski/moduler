require "test_helper"

module Moduler
  class PreferenceTest < ActiveSupport::TestCase
    def build_preference(**attributes)
      Moduler::Preference.new(kind: "boolean", name: "SOME_FLAG", value: "true", **attributes)
    end

    test "is valid with a kind, a unique name and a value" do
      preference = build_preference
      assert preference.valid?, "Expected preference to be valid, got: #{preference.errors.full_messages}"
    end

    %i[ kind name value ].each do |attribute|
      test "is invalid without #{attribute}" do
        preference = build_preference(attribute => "")
        assert_not preference.valid?
        assert_includes preference.errors[attribute], "can't be blank"
      end
    end

    test "defines the allowed kinds" do
      assert_equal %w[ string boolean integer ], Moduler::Preference::KINDS
      assert Moduler::Preference::KINDS.frozen?
    end

    test "is invalid with a kind outside string, boolean and integer" do
      preference = build_preference(kind: "float")
      assert_not preference.valid?
      assert_includes preference.errors[:kind], "is not included in the list"
    end

    test "is invalid with a duplicate name" do
      preference = build_preference(name: "WAITLIST")
      assert_not preference.valid?
      assert_includes preference.errors[:name], "has already been taken"
    end

    [ "some_flag", "Some_Flag", "1FLAG", "SOME-FLAG", "SOME FLAG", "_FLAG" ].each do |name|
      test "is invalid with name #{name.inspect} that is not a constant name" do
        preference = build_preference(name: name)
        assert_not preference.valid?
        assert_includes preference.errors[:name], "is invalid"
      end
    end

    [ "A", "FLAG", "SOME_FLAG", "FLAG_2" ].each do |name|
      test "is valid with constant name #{name.inspect}" do
        assert build_preference(name: name).valid?
      end
    end

    test "is invalid with a boolean value that is not true or false" do
      preference = build_preference(value: "1")
      assert_not preference.valid?
      assert_includes preference.errors[:value], "is not included in the list"
    end

    test "is invalid with an integer value that is not a whole number" do
      preference = build_preference(kind: "integer", value: "not-a-number")
      assert_not preference.valid?
      assert_includes preference.errors[:value], "is invalid"
    end

    test "is valid with a negative integer value" do
      assert build_preference(kind: "integer", value: "-5").valid?
    end

    test "normalizes the case and surrounding whitespace of a boolean value" do
      preference = build_preference(value: " True ")
      preference.save!

      assert_equal "true", preference.value
    end

    test "keeps a string value exactly as typed" do
      preference = build_preference(kind: "string", value: " Hello ")
      preference.save!

      assert_equal " Hello ", preference.value
    end

    test "database rejects a duplicate name" do
      assert_raises(ActiveRecord::RecordNotUnique) do
        build_preference(name: "WAITLIST").save!(validate: false)
      end
    end

    test "Preference::NAME resolves a boolean preference to true or false" do
      assert_equal true, Moduler::Preference::WAITLIST

      moduler_preferences(:waitlist).update!(value: "false")
      assert_equal false, Moduler::Preference::WAITLIST
    end

    test "Preference::NAME resolves an integer preference" do
      assert_equal 5, Moduler::Preference::MAX_PROJECTS
    end

    test "Preference::NAME resolves a string preference as is" do
      build_preference(kind: "string", name: "GREETING", value: "hello").save!

      assert_equal "hello", Moduler::Preference::GREETING
    end

    test "Preference::NAME is nil when no such preference exists" do
      assert_nil Moduler::Preference::SOME_NONEXISTENT_FLAG
    end

    test "Preference::NAME resolves a boolean value stored before normalization" do
      moduler_preferences(:waitlist).update_column(:value, " True ")

      assert_equal true, Moduler::Preference::WAITLIST
    end

    test "a missing constant that is not a preference name raises NameError" do
      assert_raises(NameError) { Moduler::Preference.const_get(:Missing) }
    end

    test "cast_value casts the value to the kind" do
      assert_equal true, moduler_preferences(:waitlist).cast_value
      assert_equal 5, moduler_preferences(:max_projects).cast_value
    end

    test "search_by_query finds preferences by name and kind" do
      assert_includes Moduler::Preference.search_by_query("WAITLIST"), moduler_preferences(:waitlist)
      assert_includes Moduler::Preference.search_by_query("integer"), moduler_preferences(:max_projects)
      assert_not_includes Moduler::Preference.search_by_query("integer"), moduler_preferences(:waitlist)
    end
  end
end
