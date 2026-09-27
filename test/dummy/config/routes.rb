Rails.application.routes.draw do
  moduler "/application" do
    root "home#index"
  end
end
