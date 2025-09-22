Rails.application.routes.draw do
    
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: "users/registrations"
  }

  resource :profile, only: [:show, :edit, :update]

  root to: "home#index" 
  get 'dashboard/index'

  resources :doctors do
    resources :patients
  end
  resources :patients
end
