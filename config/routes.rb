Rails.application.routes.draw do
  get 'nurses/index'

  devise_for :users

  resources :plannings do
  	resources :appointments
  	resources :recurring_appointments
    resources :unavailabilities
    resources :recurring_unavailabilities
    resources :nurses
    resources :patients
    resources :activities
  end

  resources :patients

  resources :nurses

  resources :corporations do
  	resources :nurses, only: :index
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'plannings#index'
end
