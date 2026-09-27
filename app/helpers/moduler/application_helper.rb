module Moduler
  module ApplicationHelper
    def stylesheet_link_tags_if_exist(*sources, **options)
      existing = sources.select { |source| Rails.application.assets.load_path.find("#{source}.css") }
      stylesheet_link_tag(*existing, **options) if existing.any?
    end
  end
end
