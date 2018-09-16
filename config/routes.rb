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

  resources :provided_services, only: [:update, :destroy]

  resources :patients

  resources :nurses do
    resources :provided_services
  end

  resources :corporations do
  	resources :nurses, only: :index
  end


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'plannings/:planning_id/nurses/:id/payable' => 'nurses#payable', as: :planning_nurse_payable

  get 'plannings/:id/duplicate_from' => 'plannings#duplicate_from', as: :planning_duplicate_from

  patch 'plannings/:id/duplicate' => 'plannings#duplicate', as: :planning_duplicate

  patch 'plannings/:id/master_to_schedule' => 'plannings#master_to_schedule', as: :master_to_schedule

  patch 'patients/:id/toggle_active' => 'patients#toggle_active', as: :toggle_active

  get 'plannings/:id/master' => 'plannings#master', as: :planning_master

  get 'plannings/:planning_id/nurses/:id/master' => 'nurses#master', as: :planning_nurse_master
 
  get 'plannings/:planning_id/patients/:id/master' => 'patients#master', as: :planning_patient_master

  patch 'users/:id/toggle_admin' => 'users#toggle_admin', as: :toggle_admin

  patch 'plannings/:planning_id/recurring_appointment/:id/from_master_to_general' => 'recurring_appointments#from_master_to_general', as: :from_master_to_general

  root 'plannings#index'
end
