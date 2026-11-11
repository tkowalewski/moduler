module Moduler
  # Runtime settings and feature toggles managed in the administration area
  # and read in code as Moduler::Preference::NAME, cast to the preference's
  # kind. A preference that does not exist reads as nil.
  class Preference < ApplicationRecord
    include PgSearch::Model

    KINDS = %w[ string boolean integer ].freeze
    NAME_FORMAT = /\A[A-Z][A-Z0-9_]*\z/

    before_validation :normalize_boolean_value

    validates :kind, presence: true, inclusion: { in: KINDS }
    validates :name, presence: true, uniqueness: true, format: { with: NAME_FORMAT }
    validates :value, presence: true
    validates :value, inclusion: { in: %w[ true false ] }, if: -> { kind == "boolean" }
    validates :value, format: { with: /\A-?\d+\z/ }, if: -> { kind == "integer" }

    pg_search_scope :search_by_query, against: %i[ kind name ], using: { trigram: { word_similarity: true } }

    class << self
      def const_missing(name)
        return super unless name.to_s.match?(NAME_FORMAT)

        find_by(name: name.to_s)&.cast_value
      end
    end

    # The value cast to the preference's kind.
    def cast_value
      case kind
      when "string" then value
      when "integer" then Integer(value)
      when "boolean" then value.to_s.strip.downcase == "true"
      end
    end

    private

    def normalize_boolean_value
      self.value = value.strip.downcase if kind == "boolean" && value.present?
    end
  end
end
