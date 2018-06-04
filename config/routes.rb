Rails.application.routes.draw do
  devise_for :users
  resources :appointments
  resources :recurring_appointments
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'appointments#index'
end
