Rails.application.routes.draw do
  resource :session
  resources :products

  root "products#index"
end
