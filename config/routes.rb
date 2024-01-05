Rails.application.routes.draw do
  namespace :api do
    get 'current_user/create'
  end

  # if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  # end

  post "/graphql", to: "graphql#execute"

  resources :work_weeks
  resources :assignments
  resources :projects
  resources :clients

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  passwordless_for :users, at: '/', as: :auth

  resource :dashboard, only: [:show], controller: "dashboard"

  namespace :staff_plans do
    resources :users, only: [:show]
    resources :work_weeks, only: [:create, :update]
  end

  get '/staff_plans', to: "staff_plans/users#show"

  root "dashboard#show"
end
