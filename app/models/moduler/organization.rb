module Moduler
  class Organization < ApplicationRecord
    include PgSearch::Model

    validates :name, presence: true, uniqueness: true

    pg_search_scope :search_by_query, against: %i[ name ], using: { trigram: { word_similarity: true } }
  end
end
