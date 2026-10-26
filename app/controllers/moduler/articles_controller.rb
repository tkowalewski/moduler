module Moduler
  class ArticlesController < ApplicationController
    layout "moduler/articles"

    allow_unauthenticated_access

    def index
      @articles = Article.order(created_at: :desc).page(params[:page])
    end

    def show
      @article = Article.find_by!(path: params[:path])
    end
  end
end
