Rails.application.routes.draw do
  resources :passwords
  root 'passwords#index'
end
