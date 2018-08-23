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

  resources :recurring_appointments do
    resources :deleted_occurrences, only: [:new, :create]
  end

  resources :provided_services, only: [:update, :show]

  resources :patients

  resources :nurses

  resources :corporations do
  	resources :nurses, only: :index
  end


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'plannings/:planning_id/nurses/:id/payable' => 'nurses#payable', as: :planning_nurse_payable

  get 'plannings/:id/duplicate_from' => 'plannings#duplicate_from', as: :planning_duplicate_from

  patch 'plannings/:id/duplicate' => 'plannings#duplicate', as: :planning_duplicate

  patch 'plannings/:id/master_to_schedule' => 'plannings#master_to_schedule', as: :master_to_schedule

  get 'plannings/:id/master' => 'plannings#master', as: :planning_master

  patch 'users/:id/toggle_admin' => 'users#toggle_admin', as: :toggle_admin

  root 'plannings#index'
end
