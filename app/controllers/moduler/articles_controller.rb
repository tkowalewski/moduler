module Moduler
  class ArticlesController < ApplicationController
    layout "moduler/articles"

    allow_unauthenticated_access
    skip_document_acceptance

    def index
      @articles = Article.published.order(created_at: :desc).page(params[:page])
    end

    def show
      @article = Article.published.find_by!(path: params[:path])
    end
  end
end
