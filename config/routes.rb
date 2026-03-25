Moduler::Engine.routes.draw do
  resource :session, only: %i[new create destroy]
  resource :user, only: %i[new create]

  root "home#index"
end
