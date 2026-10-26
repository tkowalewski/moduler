Moduler::Engine.routes.draw do
  resources :articles, only: %i[ index show ], param: :path

  resource :session, only: %i[new create destroy]
  resource :user, only: %i[new create]

  resource :profile, only: %i[ edit update ], controller: :profile
  namespace :profile do
    namespace :sessions do
      resource :revocation, only: :destroy, controller: :revocation
    end
    resources :sessions, only: %i[ index destroy ]
  end

  namespace :administration do
    resources :users, only: %i[ index new create edit update ]
    resources :sessions, only: %i[ index destroy ]

    resources :articles

    root "home#index"
  end

  root "home#index"
end
