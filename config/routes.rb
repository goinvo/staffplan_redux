Rails.application.routes.draw do
  resources :work_weeks
  resources :assignments
  resources :projects
  resources :clients

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  passwordless_for :users, at: '/', as: :auth

  resource :dashboard, only: [:show], controller: "dashboard"

  resources :staff_plans, only: [:show], controller: "staff_plan/users"
  get '/staff_plan', to: "staff_plan/users#show"

  root "dashboard#show"
end
