Moduler::Engine.routes.draw do
  resource :session, only: %i[new create destroy]
  resource :user, only: %i[new create]

  get "/hello", to: "hello#index"

  root "home#index"
end
