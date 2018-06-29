Rails.application.routes.draw do
  get 'nurses/index'

  devise_for :users, controllers: {
    invitations: "invitations"
  }

  resources :users, only: [:index, :edit, :update]

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

  get 'plannings/:id/master' => 'plannings#master', as: :planning_master

  patch 'users/:id/toggle_admin' => 'users#toggle_admin', as: :toggle_admin

  root 'plannings#index'
end
