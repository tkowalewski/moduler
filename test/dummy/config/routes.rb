Rails.application.routes.draw do
  moduler "/application" do
    namespace :administration do
      resources :tasks
    end
  end
end
