Rails.application.routes.draw do
  resources :contacts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "home#index"
  resources :batches, except: :new do
    collection do
      get :unpaid
    end
  end
  resources :entries, only: :destroy do
    collection do
      get :trial_balance
    end
  end
  resources :tranzactions
  resources :accounts, except: [:show, :destroy]
  resources :payments, only: [:print, :update]
end
