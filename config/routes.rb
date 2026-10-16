Moduler::Engine.routes.draw do
  resource :session, only: %i[new create destroy]
  resource :user, only: %i[new create]

  resource :profile, only: %i[ edit update ], controller: :profile
  namespace :profile do
    namespace :sessions do
      resource :revocation, only: :destroy, controller: :revocation
    end
    resources :sessions, only: %i[ index destroy ]
  end

  get "/hello", to: "hello#index"

  root "home#index"
end
