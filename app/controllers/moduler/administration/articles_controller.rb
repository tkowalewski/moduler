module Moduler
  module Administration
    class ArticlesController < ApplicationController
      before_action -> { authorize([ :moduler, :administration, :article ]) }
      before_action :set_article, only: %i[ edit update destroy ]

      def index
        @filter, @articles = QueryFilter.new(Article, permitted_filter_parameters).call
      end

      def new
        @article = Article.new
      end

      def create
        @article = Article.new(permitted_parameters)

        if @article.save
          redirect_to moduler.administration_articles_path, notice: t(".notice")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit; end

      def update
        if @article.update(permitted_parameters)
          redirect_to moduler.administration_articles_path, notice: t(".notice")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @article.destroy!

        redirect_to moduler.administration_articles_path, status: :see_other, notice: t(".notice")
      end

      private

      def set_article
        @article = Article.find(params[:id])
        authorize(@article, policy_class: ArticlePolicy)
      end

      def permitted_parameters
        params.expect(article: [ :path, :title, :description, :keywords, :content, images: [] ])
      end

      def permitted_filter_parameters
        (params.permit(filter: %i[ query ])[:filter] || {}).merge(params.permit(:page))
      end
    end
  end
end
