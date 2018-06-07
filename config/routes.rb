Rails.application.routes.draw do
  get 'nurses/index'

  devise_for :users

  resources :plannings do
  	resources :appointments
  	resources :recurring_appointments
    resources :nurses
    resources :patients
  end

  resources :activities

  resources :patients, only: [:new, :create]

  resources :nurses, only: [:new, :create]

  resources :corporations do
  	resources :nurses, only: :index
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'plannings#index'
end
