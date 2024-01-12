Rails.application.routes.draw do
  namespace :api do
    get 'current_user/create'
  end

  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql", constraints: lambda { |request|
    # only allow authenticated users, otherwise 404
    Passwordless::Session.exists?(id: request.session[:"passwordless_session_id--user"])
  }

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

  root "dashboard#show"
end
