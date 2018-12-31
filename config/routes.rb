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
    resources :scans
    resources :services, only: :index
    resources :printing_options, only: :show
  end

  resources :services, except: :index

  resources :recurring_appointments do
    resources :deleted_occurrences, only: [:new, :create]
  end

  resources :provided_services, only: [:update, :destroy]

  resources :patients

  resources :posts

  resources :nurses do
    resources :provided_services
    resources :services
  end

  resources :corporations do
    resources :nurses, only: :index
    resources :patients, only: :index
    resources :printing_options, only: :update
  end

  resources :dashboard, only: :index

  resources :teams


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  #custom routes for users
  patch 'users/:id/toggle_admin' => 'users#toggle_admin', as: :toggle_admin
  get 'users/:id/edit_role' => 'users#edit_role', as: :edit_user_role
  patch 'users/:id/update_role' => 'users#update_role', as: :update_user_role
  
  #custom routes for provided services
  patch 'provided_services/:id/verify' => 'provided_services#verify', as: :verify_provided_service
  
  #custom routes for nurses
  get 'plannings/:planning_id/nurses/:id/payable' => 'nurses#payable', as: :planning_nurse_payable
  get 'plannings/:planning_id/nurses/:id/master' => 'nurses#master', as: :planning_nurse_master
  get 'nurses/:id/new_reminder_email' => 'nurses#new_reminder_email', as: :nurse_new_reminder_email
  patch 'nurses/:id/send_reminder_email' => 'nurses#send_reminder_email', as: :nurse_send_reminder_email
  patch 'plannings/:planning_id/nurses/:id/master_to_schedule' => 'nurses#master_to_schedule', as: :nurse_master_to_schedule
  
  #custom routes for patients
  get 'plannings/:planning_id/patients/:id/master' => 'patients#master', as: :planning_patient_master
  patch 'patients/:id/toggle_active' => 'patients#toggle_active', as: :toggle_active
  patch 'plannings/:planning_id/patients/:id/master_to_schedule' => 'patients#master_to_schedule', as: :patient_master_to_schedule
  
  #custom routes for plannings
  get 'plannings/:id/monthly_general_report' => 'plannings#monthly_general_report', as: :planning_monthly_general_report
  get 'plannings/:id/settings' => 'plannings#settings', as: :planning_settings
  get 'plannings/:id/master' => 'plannings#master', as: :planning_master
  get 'plannings/:id/payable' => 'plannings#payable', as: :planning_payable
  get 'plannings/:id/duplicate_from' => 'plannings#duplicate_from', as: :planning_duplicate_from
  patch 'plannings/:id/duplicate' => 'plannings#duplicate', as: :planning_duplicate
  patch 'plannings/:id/master_to_schedule' => 'plannings#master_to_schedule', as: :master_to_schedule
  patch 'plannings/:id/archive' => 'plannings#archive', as: :planning_archive

  #custom routes for appointments
  patch 'plannings/:planning_id/appointments/:id/toggle_cancelled' => 'appointments#toggle_cancelled', as: :planning_appointment_toggle_cancelled
  patch 'plannings/:planning_id/appointments/:id/toggle_edit_requested' => 'appointments#toggle_edit_requested', as: :planning_appointment_toggle_edit_requested
  patch 'plannings/:planning_id/appointments/:id/archive' => 'appointments#archive', as: :planning_appointment_archive
  get 'appointments/new_batch_archive' => 'appointments#new_batch_archive', as: :new_appointments_batch_archive
  get 'appointments/batch_archive_confirm' => 'appointments#batch_archive_confirm', as: :appointments_batch_archive_confirm
  patch 'appointments/batch_archive' => 'appointments#batch_archive', as: :appointments_batch_archive
  get 'appointments/new_batch_cancel' => 'appointments#new_batch_cancel', as: :new_appointments_batch_cancel
  get 'appointments/batch_cancel_confirm' => 'appointments#batch_cancel_confirm', as: :appointments_batch_cancel_confirm
  patch 'appointments/batch_cancel' => 'appointments#batch_cancel', as: :appointments_batch_cancel
  get 'appointments/new_batch_request_edit' => 'appointments#new_batch_request_edit', as: :new_appointments_batch_request_edit
  get 'appointments/batch_request_edit_confirm' => 'appointments#batch_request_edit_confirm', as: :appointments_batch_request_edit_confirm
  patch 'appointments/batch_request_edit' => 'appointments#batch_request_edit', as: :appointments_batch_request_edit 
  
  #custom routes for recurring_appointments
  patch 'plannings/:planning_id/recurring_appointments/:id/toggle_edit_requested' => 'recurring_appointments#toggle_edit_requested', as: :planning_recurring_appointment_toggle_edit_requested
  patch 'planning/:planning_id/recurring_appointments/:id/archive' => 'recurring_appointments#archive', as: :planning_recurring_appointment_archive
  patch 'plannings/:planning_id/recurring_appointment/:id/from_master_to_general' => 'recurring_appointments#from_master_to_general', as: :from_master_to_general
  patch 'plannings/:planning_id/recurring_appointments/:id/toggle_cancelled' => 'recurring_appointments#toggle_cancelled', as: :planning_recurring_appointment_toggle_cancelled

  #custom routes for tags
  get '/tags' => 'tags#index'

  #custom routes for dashboard
  get 'dashboard/extended_daily_summary' => 'dashboard#extended_daily_summary', as: :dashboard_extended_daily_summary

  root 'dashboard#index'
end
