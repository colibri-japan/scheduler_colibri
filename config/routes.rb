Rails.application.routes.draw do

  match '(*any)', to: redirect(subdomain: ''), via: :all, constraints: {subdomain: ['www', 'scheduler']}
  get 'bonuses/new'

  get 'calendar_event/new'

  get 'contact_form/new'

  get 'contact_form/create'

  get 'tags/index'

  devise_for :users, controllers: {
    invitations: "invitations",
    sessions: "sessions",
    registrations: "registrations"
  }

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :users, only: [:index, :edit, :update]


  resources :plannings do
  	resources :appointments, except: [:destroy, :new]
  	resources :recurring_appointments, except: :destroy
    resources :private_events, except: :new
    resources :wished_slots
    resources :nurses
    resources :patients
    resources :activities
    resources :scans
    resources :printing_options, only: :show
    resources :teams, only: :show
  end

  resources :services

  resources :care_manager_corporations do
    resources :care_managers
  end


  resources :calendar_events, only: :new

  resources :salary_line_items, only: [:update, :destroy]

  resources :patients do 
    resources :care_plans
  end

  resources :posts

  resources :appointments, except: [:destroy, :new] do
    resources :completion_reports, except: [:index, :destroy]
  end

  resources :recurring_appointments do 
    resources :completion_reports, except: [:index, :destroy]
  end

  resources :completion_reports, only:[:index, :destroy]

  resources :nurses do
    resources :salary_line_items, except: [:new]
    resources :bonuses, only: :new
    resources :nurse_service_wages, only: :index
    resources :completion_reports, only: :index
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
  get 'teams/:id/revenue_per_nurse_report' => 'teams#revenue_per_nurse_report', as: :team_revenue_per_nurse_report
  get 'teams/:id/new_master_to_schedule' => 'teams#new_master_to_schedule', as: :new_team_master_to_schedule
  patch 'teams/:id/master_to_schedule' => 'teams#master_to_schedule', as: :team_master_to_schedule

  #custom routes for corporations
  get 'corporations/:id/revenue_per_team_report' => 'corporations#revenue_per_team_report', as: :corporation_revenue_per_team_report
  get 'corporations/:id/new_email_monthly_nurse_wages' => 'corporations#new_email_monthly_nurse_wages', as: :corporation_new_email_monthly_nurse_wages
  get 'corporations/:id/email_monthly_nurse_wages' => 'corporations#email_monthly_nurse_wages', as: :corporation_email_monthly_nurse_wages

  #custom routes for users
  patch 'users/:id/toggle_admin' => 'users#toggle_admin', as: :toggle_admin
  get 'users/:id/edit_role' => 'users#edit_role', as: :edit_user_role
  patch 'users/:id/update_role' => 'users#update_role', as: :update_user_role
  get 'users/current_user_home' => 'users#current_user_home', as: :current_user_home
  
  #custom routes for nurses
  get 'plannings/:planning_id/nurses/:id/payable' => 'nurses#payable', as: :planning_nurse_payable
  get 'nurses/:id/new_reminder_email' => 'nurses#new_reminder_email', as: :nurse_new_reminder_email
  patch 'nurses/:id/send_reminder_email' => 'nurses#send_reminder_email', as: :nurse_send_reminder_email
  patch 'nurses/:id/master_to_schedule' => 'nurses#master_to_schedule', as: :nurse_master_to_schedule
  get 'nurses/:id/new_master_to_schedule' => "nurses#new_master_to_schedule", as: :new_nurse_master_to_schedule
  get 'master_availabilities/nurses' => 'nurses#master_availabilities', as: :nurses_master_availabilities
  patch 'nurses/:id/archive' => 'nurses#archive', as: :nurse_archive
  patch 'nurses/:id/recalculate_salary' => 'nurses#recalculate_salary', as: :nurse_recalculate_salary
  get 'smart_search/nurses' => 'nurses#smart_search', as: :nurses_smart_search
  get 'smart_search_results/nurses' => 'nurses#smart_search_results', as: :nurses_smart_search_results

  #custom routes for patients
  patch 'patients/:id/toggle_active' => 'patients#toggle_active', as: :toggle_active
  patch 'patients/:id/master_to_schedule' => 'patients#master_to_schedule', as: :patient_master_to_schedule
  get 'patients/:id/new_master_to_schedule' => "patients#new_master_to_schedule", as: :new_patient_master_to_schedule
  get 'plannings/:planning_id/patients/:id/payable' => 'patients#payable', as: :planning_patient_payable
  get 'patients/:id/commented_appointments' => 'patients#commented_appointments', as: :patient_commented_appointments
  get 'patients/:id/teikyohyo' => 'patients#teikyohyo', as: :patient_teikyohyo
  get 'patients/:id/new_extract_care_plan' => 'patients#new_extract_care_plan', as: :patient_new_extract_care_plan
  get 'patients/:id/extract_care_plan' => 'patients#extract_care_plan', as: :patient_extract_care_plan
  get 'search_by_kana_group/patients' => 'patients#search_by_kana_group', as: :patients_search_by_kana_group

  #custom routes for plannings
  get 'plannings/:id/monthly_general_report' => 'plannings#monthly_general_report', as: :planning_monthly_general_report
  get 'plannings/:id/monthly_appointments_report' => 'plannings#monthly_appointments_report', as: :planning_monthly_appointments_report
  get 'plannings/:id/teams_report' => 'plannings#teams_report', as: :planning_teams_report
  get 'plannings/:id/recent_patients_report' => 'plannings#recent_patients_report', as: :planning_recent_patients_report
  get 'plannings/:id/master' => 'plannings#master', as: :planning_master
  get 'plannings/:id/all_nurses_payable' => 'plannings#all_nurses_payable', as: :planning_all_nurses_payable
  get 'plannings/:id/all_patients_payable' => 'plannings#all_patients_payable', as: :planning_all_patients_payable
  get 'plannings/:id/duplicate_from' => 'plannings#duplicate_from', as: :planning_duplicate_from
  patch 'plannings/:id/duplicate' => 'plannings#duplicate', as: :planning_duplicate
  patch 'plannings/:id/master_to_schedule' => 'plannings#master_to_schedule', as: :master_to_schedule
  get 'plannings/:id/new_master_to_schedule' => 'plannings#new_master_to_schedule', as: :new_planning_master_to_schedule
  get 'plannings/:id/cancelled_report' => 'plannings#cancelled_report', as: :planning_cancelled_report  
  get 'plannings/:id/completion_reports_summary' => 'plannings#completion_reports_summary', as: :planning_completion_reports_summary

  #custom routes for appointments
  patch 'plannings/:planning_id/appointments/:id/toggle_cancelled' => 'appointments#toggle_cancelled', as: :planning_appointment_toggle_cancelled
  patch 'plannings/:planning_id/appointments/:id/toggle_edit_requested' => 'appointments#toggle_edit_requested', as: :planning_appointment_toggle_edit_requested
  patch 'plannings/:planning_id/appointments/:id/archive' => 'appointments#archive', as: :planning_appointment_archive
  get 'new_batch_action/appointments' => 'appointments#new_batch_action', as: :new_appointments_batch_action
  get 'batch_action_confirm/appointments' => 'appointments#batch_action_confirm', as: :appointments_batch_action_confirm
  patch 'batch_archive/appointments' => 'appointments#batch_archive', as: :appointments_batch_archive
  patch 'batch_cancel/appointments' => 'appointments#batch_cancel', as: :appointments_batch_cancel
  patch 'batch_restore_to_operational/appointments' => 'appointments#batch_restore_to_operational', as: :appointments_batch_restore_to_operational
  patch 'batch_request_edit/appointments' => 'appointments#batch_request_edit', as: :appointments_batch_request_edit 
  patch 'appointments/:id/toggle_verified' => 'appointments#toggle_verified', as: :toggle_verified_appointment
  patch 'appointments/:id/toggle_second_verified' => 'appointments#toggle_second_verified', as: :toggle_second_verified_appointment
  get 'appointments/:id/new_cancellation_fee' => 'appointments#new_cancellation_fee', as: :appointment_new_cancellation_fee
  get 'appointments_by_category_report/appointments' => 'appointments#appointments_by_category_report', as: :appointments_by_category_report
  get 'monthly_revenue_report/appointments' => 'appointments#monthly_revenue_report', as: :appointments_monthly_revenue_report

  #custom routes for recurring_appointments
  patch 'planning/:planning_id/recurring_appointments/:id/archive' => 'recurring_appointments#archive', as: :planning_recurring_appointment_archive
  patch 'plannings/:planning_id/recurring_appointments/:id/terminate' => 'recurring_appointments#terminate', as: :planning_recurring_appointment_terminate 
  patch 'plannings/:planning_id/recurring_appointments/:id/create_individual_appointments' => 'recurring_appointments#create_individual_appointments', as: :planning_recurring_appointment_create_individual_appointments

  #custom routes for nurse_service_wages
  patch 'nurses/:nurse_id/services/:service_id/set_nurse_wage' => 'nurse_service_wages#set_nurse_wage', as: :set_nurse_service_wage

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

  root to: 'pages#show', page: 'home'

end
