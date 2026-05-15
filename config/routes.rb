Rails.application.routes.draw do

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: "users/registrations"
  }

  resource :profile, only: [:show, :edit, :update]

  root to: "home#index" 
  get 'dashboard/index'

  resources :doctors do
    resources :patients do
      resources :appointments
    end
  end

  resources :patients
  resources :appointments
  resources :medical_records
  resources :diagnoses
  resources :treatments
  
  resources :laboratory_results do
    member  do
      patch :collect_sample
      patch :start_processing
      patch :complete_report
      patch :send_report
    end
  end

  resources :patient_appointments, only: [:index, :new, :create]

  resources :invoices do
    member do
      patch :mark_paid
      get :download_pdf
    end
  end
end
