Rails.application.routes.draw do
  moduler "/application" do
    namespace :administration do
      resources :tasks
    end
  end

  get "/articles", to: redirect("/application/articles")
  get "/articles/:path", to: redirect("/application/articles/%{path}")
end
