Rails.application.routes.draw do
  moduler "/application" do
    resources :organizations, only: [] do
      resources :reports, only: :index
      resources :projects, only: :index
    end

    namespace :administration do
      resources :tasks
    end
  end

  get "/articles", to: redirect("/application/articles")
  get "/articles/:path", to: redirect("/application/articles/%{path}")
end
