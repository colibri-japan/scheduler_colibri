Rails.application.routes.draw do

  get 'bonuses/new'

  get 'calendar_event/new'

  get 'contact_form/new'

  get 'contact_form/create'

  get 'tags/index'

  devise_for :users, controllers: {
    invitations: "invitations",
    sessions: "sessions"
  }

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :users, only: [:index, :edit, :update]


  resources :plannings do
  	resources :appointments, except: :destroy
  	resources :recurring_appointments, except: :destroy
    resources :private_events
    resources :wished_slots
    resources :nurses
    resources :patients
    resources :activities
    resources :scans
    resources :services, only: :index
    resources :printing_options, only: :show
    resources :teams, only: :show
  end

  resources :services, except: :index

  resources :care_manager_corporations do
    resources :care_managers
  end


  resources :calendar_events, only: :new

  resources :provided_services, only: [:update, :destroy]

  resources :patients

  resources :posts

  resources :appointments, except: :destroy do
    resources :completion_reports, only: [:new, :create, :edit, :update]
  end

  resources :nurses do
    resources :provided_services
    resources :services
    resources :bonuses, only: :new
  end

  resources :corporations do
    resources :nurses, only: :index
    resources :patients, only: :index
    resources :printing_options, only: :update
  end

  resources :dashboard, only: :index

  resources :teams

  resources :contact_forms, only: [:new, :create]

  resources :salary_rules


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  #custom routes for static pages
  get "/pages/*page" => "pages#show", as: :pages

  #custom routes for teams
  get 'plannings/:planning_id/teams/:id/payable' => 'teams#payable', as: :planning_team_payable
  get 'plannings/:planning_id/teams/:id/master' => 'teams#master', as: :planning_team_master

  #custom routes for users
  patch 'users/:id/toggle_admin' => 'users#toggle_admin', as: :toggle_admin
  get 'users/:id/edit_role' => 'users#edit_role', as: :edit_user_role
  patch 'users/:id/update_role' => 'users#update_role', as: :update_user_role
  
  #custom routes for provided services
  patch 'provided_services/:id/toggle_verified' => 'provided_services#toggle_verified', as: :toggle_verified_provided_service
  patch 'provided_services/:id/toggle_second_verified' => 'provided_services#toggle_second_verified', as: :toggle_second_verified_provided_service
  get 'provided_services/:id/new_cancellation_fee' => 'provided_services#new_cancellation_fee', as: :provided_service_new_cancellation_fee

  #custom routes for nurses
  get 'plannings/:planning_id/nurses/:id/payable' => 'nurses#payable', as: :planning_nurse_payable
  get 'plannings/:planning_id/nurses/:id/master' => 'nurses#master', as: :planning_nurse_master
  get 'nurses/:id/new_reminder_email' => 'nurses#new_reminder_email', as: :nurse_new_reminder_email
  patch 'nurses/:id/send_reminder_email' => 'nurses#send_reminder_email', as: :nurse_send_reminder_email
  patch 'nurses/:id/master_to_schedule' => 'nurses#master_to_schedule', as: :nurse_master_to_schedule
  get 'nurses/:id/new_master_to_schedule' => "nurses#new_master_to_schedule", as: :new_nurse_master_to_schedule
  get 'master_availabilities/nurses' => 'nurses#master_availabilities', as: :nurses_master_availabilities

  #custom routes for patients
  get 'plannings/:planning_id/patients/:id/master' => 'patients#master', as: :planning_patient_master
  patch 'patients/:id/toggle_active' => 'patients#toggle_active', as: :toggle_active
  patch 'patients/:id/master_to_schedule' => 'patients#master_to_schedule', as: :patient_master_to_schedule
  get 'patients/:id/new_master_to_schedule' => "patients#new_master_to_schedule", as: :new_patient_master_to_schedule
  get 'plannings/:planning_id/patients/:id/payable' => 'patients#payable', as: :planning_patient_payable
  get 'patients/:id/commented_appointments' => 'patients#commented_appointments', as: :patient_commented_appointments
  #custom routes for plannings
  get 'plannings/:id/monthly_general_report' => 'plannings#monthly_general_report', as: :planning_monthly_general_report
  get 'plannings/:id/teams_report' => 'plannings#teams_report', as: :planning_teams_report
  get 'plannings/:id/recent_patients_report' => 'plannings#recent_patients_report', as: :planning_recent_patients_report
  get 'plannings/:id/master' => 'plannings#master', as: :planning_master
  get 'plannings/:id/all_nurses_payable' => 'plannings#all_nurses_payable', as: :planning_all_nurses_payable
  get 'plannings/:id/all_patients_payable' => 'plannings#all_patients_payable', as: :planning_all_patients_payable
  get 'plannings/:id/duplicate_from' => 'plannings#duplicate_from', as: :planning_duplicate_from
  patch 'plannings/:id/duplicate' => 'plannings#duplicate', as: :planning_duplicate
  patch 'plannings/:id/master_to_schedule' => 'plannings#master_to_schedule', as: :master_to_schedule
  patch 'plannings/:id/archive' => 'plannings#archive', as: :planning_archive
  get 'plannings/:id/new_master_to_schedule' => 'plannings#new_master_to_schedule', as: :new_planning_master_to_schedule
  get 'plannings/:id/all_patients' => 'plannings#all_patients', as: :planning_all_patients
  get 'plannings/:id/all_nurses' => 'plannings#all_nurses', as: :planning_all_nurses
  get 'plannings/:id/all_patients_master' => 'plannings#all_patients_master', as: :planning_all_patients_master
  get 'plannings/:id/all_nurses_master' => 'plannings#all_nurses_master', as: :planning_all_nurses_master

  #custom routes for appointments
  patch 'plannings/:planning_id/appointments/:id/toggle_cancelled' => 'appointments#toggle_cancelled', as: :planning_appointment_toggle_cancelled
  patch 'plannings/:planning_id/appointments/:id/toggle_edit_requested' => 'appointments#toggle_edit_requested', as: :planning_appointment_toggle_edit_requested
  patch 'plannings/:planning_id/appointments/:id/archive' => 'appointments#archive', as: :planning_appointment_archive
  get 'new_batch_archive/appointments' => 'appointments#new_batch_archive', as: :new_appointments_batch_archive
  get 'batch_archive_confirm/appointments' => 'appointments#batch_archive_confirm', as: :appointments_batch_archive_confirm
  patch 'batch_archive/appointments' => 'appointments#batch_archive', as: :appointments_batch_archive
  get 'new_batch_cancel/appointments' => 'appointments#new_batch_cancel', as: :new_appointments_batch_cancel
  get 'batch_cancel_confirm/appointments' => 'appointments#batch_cancel_confirm', as: :appointments_batch_cancel_confirm
  patch 'batch_cancel/appointments' => 'appointments#batch_cancel', as: :appointments_batch_cancel
  get 'new_batch_request_edit/appointments' => 'appointments#new_batch_request_edit', as: :new_appointments_batch_request_edit
  get 'batch_request_edit_confirm/appointments' => 'appointments#batch_request_edit_confirm', as: :appointments_batch_request_edit_confirm
  patch 'batch_request_edit/appointments' => 'appointments#batch_request_edit', as: :appointments_batch_request_edit 
  
  #custom routes for recurring_appointments
  patch 'planning/:planning_id/recurring_appointments/:id/archive' => 'recurring_appointments#archive', as: :planning_recurring_appointment_archive
  patch 'plannings/:planning_id/recurring_appointments/:id/terminate' => 'recurring_appointments#terminate', as: :planning_recurring_appointment_terminate 
  patch 'plannings/:planning_id/recurring_appointments/:id/create_individual_appointments' => 'recurring_appointments#create_individual_appointments', as: :planning_recurring_appointment_create_individual_appointments

  #custom routes for tags
  get '/tags' => 'tags#index'

  #custom routes for dashboard
  get 'dashboard/extended_daily_summary' => 'dashboard#extended_daily_summary', as: :dashboard_extended_daily_summary

  #custom routes for posts
  patch 'users/:user_id/posts/mark_all_posts_as_read' => 'posts#mark_all_posts_as_read', as: :mark_all_posts_as_read
  get 'posts_widget' => 'posts#posts_widget', as: :posts_widget

  #custom routes for activities
  get 'activities_widget' => 'activities#activities_widget', as: :activities_widget

  #custom routes for services
  get 'services/:id/new_merge_and_destroy' => 'services#new_merge_and_destroy', as: :service_new_merge_and_destroy
  patch 'services/:id/merge_and_destroy' => 'services#merge_and_destroy', as: :service_merge_and_destroy


  #custom routes for care manager corporations
  get 'care_manager_corporations/:id/teikyohyo' => 'care_manager_corporations#teikyohyo', as: :care_manager_corporation_teikyohyo
  get 'care_manager_corporations/:id/commented_appointments' => 'care_manager_corporations#commented_appointments', as: :care_manager_corporation_commented_appointments

  authenticated :user do  
    root  to: 'dashboard#index', as: :authenticated_root
  end
  unauthenticated do 
    root to: 'pages#show', page: 'home', as: :unauthenticated_root
  end

end
