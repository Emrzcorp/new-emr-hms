Rails.application.routes.draw do
  get 'dashboard/index'
  
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  root to: "home#index" 
end
