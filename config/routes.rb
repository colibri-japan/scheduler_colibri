Rails.application.routes.draw do

  get 'tags/index'

  devise_for :users, controllers: {
    invitations: "invitations"
  }

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

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

  resources :services, only: [:destroy]

  resources :recurring_appointments do
    resources :deleted_occurrences, only: [:new, :create]
  end

  resources :provided_services, only: [:update, :destroy]

  resources :patients

  resources :posts, only: [:new, :create, :destroy]

  resources :nurses do
    resources :provided_services
    resources :services
  end

  resources :corporations do
    resources :nurses, only: :index
    resources :patients, only: :index
  end

  resources :dashboard, only: :index


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/tags' => 'tags#index'

  get 'plannings/:planning_id/nurses/:id/payable' => 'nurses#payable', as: :planning_nurse_payable

  get 'plannings/:id/duplicate_from' => 'plannings#duplicate_from', as: :planning_duplicate_from

  patch 'plannings/:id/duplicate' => 'plannings#duplicate', as: :planning_duplicate

  patch 'plannings/:id/master_to_schedule' => 'plannings#master_to_schedule', as: :master_to_schedule

  patch 'patients/:id/toggle_active' => 'patients#toggle_active', as: :toggle_active

  get 'plannings/:id/master' => 'plannings#master', as: :planning_master

  get 'plannings/:planning_id/nurses/:id/master' => 'nurses#master', as: :planning_nurse_master
 
  get 'plannings/:planning_id/patients/:id/master' => 'patients#master', as: :planning_patient_master

  get 'nurses/:id/new_reminder_email' => 'nurses#new_reminder_email', as: :nurse_new_reminder_email

  patch 'nurses/:id/send_reminder_email' => 'nurses#send_reminder_email', as: :nurse_send_reminder_email

  patch 'users/:id/toggle_admin' => 'users#toggle_admin', as: :toggle_admin

  patch 'plannings/:planning_id/appointments/:id/toggle_edit_requested' => 'appointments#toggle_edit_requested', as: :planning_appointment_toggle_edit_requested

  patch 'plannings/:planning_id/appointments/:id/archive' => 'appointments#archive', as: :planning_appointment_archive

  patch 'plannings/:planning_id/recurring_appointments/:id/toggle_edit_requested' => 'recurring_appointments#toggle_edit_requested', as: :planning_recurring_appointment_toggle_edit_requested

  patch 'planning/:planning_id/recurring_appointments/:id/archive' => 'recurring_appointments#archive', as: :planning_recurring_appointment_archive

  patch 'plannings/:planning_id/recurring_appointment/:id/from_master_to_general' => 'recurring_appointments#from_master_to_general', as: :from_master_to_general

  patch 'plannings/:planning_id/patients/:id/master_to_schedule' => 'patients#master_to_schedule', as: :patient_master_to_schedule

  patch 'plannings/:planning_id/nurses/:id/master_to_schedule' => 'nurses#master_to_schedule', as: :nurse_master_to_schedule

  patch 'plannings/:id/archive' => 'plannings#archive', as: :planning_archive

  get 'plannings/:id/settings' => 'plannings#settings', as: :planning_settings

  root 'dashboard#index'
end
