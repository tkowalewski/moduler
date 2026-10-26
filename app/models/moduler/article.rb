module Moduler
  class Article < ApplicationRecord
    include PgSearch::Model

    PATH_FORMAT = /\A[a-z0-9]+(-[a-z0-9]+)*\z/

    has_many_attached :images

    validates :path, presence: true, uniqueness: true, format: { with: PATH_FORMAT }
    validates :title, presence: true
    validates :description, presence: true
    validates :keywords, presence: true
    validates :content, presence: true
    validates :images, content_type: %w[ image/png image/jpeg image/gif image/webp ], size: { less_than: 10.megabytes }

    pg_search_scope :search_by_query, against: %i[ title keywords ], using: { trigram: { word_similarity: true } }
  end
end
