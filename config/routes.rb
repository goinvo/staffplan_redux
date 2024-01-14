Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql", constraints: lambda { |request|
    # only allow authenticated users, otherwise 404
    Passwordless::Session.exists?(id: request.session[:"passwordless_session_id--user"])
  }

  post "/graphql", to: "graphql#execute"

  resources :assignments
  resources :projects
  resources :clients
  resources :registrations, only: [:new, :create] do
    member do
      get :register
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  passwordless_for :users, at: '/', as: :auth

  resource :dashboard, only: [:show], controller: "dashboard"

  resource :settings, only: [:show, :update], controller: "settings" do
    resource :billing_information, only: [:show, :edit, :update], controller: "settings/billing_information"
  end

  root "dashboard#show"
end
