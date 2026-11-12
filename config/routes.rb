Moduler::Engine.routes.draw do
  resources :articles, only: %i[ index show ], param: :path

  resource :session, only: %i[new create destroy]
  resource :user, only: %i[new create]

  resource :document_acceptance, only: %i[ new create ]

  resources :organizations, only: :show

  resource :profile, only: %i[ edit update ], controller: :profile
  namespace :profile do
    namespace :sessions do
      resource :revocation, only: :destroy, controller: :revocation
    end
    resources :sessions, only: %i[ index destroy ]
    resources :sent_emails, only: %i[ index show ]
  end

  namespace :administration do
    resources :users, only: %i[ index new create edit update ]
    resources :sessions, only: %i[ index destroy ]

    resources :articles
    resources :documents, only: %i[ index new create edit update ]
    resources :preferences, only: %i[ index new create edit update destroy ]
    resources :emails, only: %i[ index new create edit update destroy ] do
      scope module: :emails do
        resources :deliveries, only: %i[ new create ]
      end
    end
    resources :organizations, only: %i[ index new create edit update ]
    resources :roles, only: %i[ index new create edit update ]
    resources :memberships, only: %i[ index new create edit update destroy ]

    root "home#index"
  end

  root "home#index"
end
