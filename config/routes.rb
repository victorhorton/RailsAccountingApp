Rails.application.routes.draw do
  resources :contacts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "home#index"
  resources :batches, except: :new
  resources :entries, only: :destroy
  resources :tranzactions
  resources :accounts, except: [:show, :destroy]
end
