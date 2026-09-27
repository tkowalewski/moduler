Moduler::Engine.routes.draw do
  scope Moduler.router.path do
    resource :session, only: %i[new create destroy]
    resource :user, only: %i[new create]

    get "/hello", to: "hello#index"
  end
end

Moduler::Engine.routes.append do
  mapper = ActionDispatch::Routing::Mapper.new(@set)
  mapper.scope(Moduler.router.path) do
    mapper.instance_exec(&Moduler.router.routes)
  end
end
