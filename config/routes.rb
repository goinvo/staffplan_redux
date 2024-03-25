require 'sidekiq/web'

Rails.application.routes.draw do
  # TODO: some kind of auth here
  mount Sidekiq::Web => '/sidekiq'

  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql", constraints: lambda { |request|
    # only allow authenticated users, otherwise 404
    Passwordless::Session.exists?(id: request.session[:"passwordless_session_id--user"])
  }

  post "/graphql", to: "graphql#execute"

  resources :assignments
  resources :projects, except: [:destroy]
  resources :clients, except: [:destroy] do
    member do
      post :toggle_archived
    end
  end
  resources :registrations, only: [:new, :create] do
    member do
      get :register
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  passwordless_for :users, at: '/', as: :auth

  resource :dashboard, only: [:show], controller: "dashboard" do
    collection do
      post :switch_account
    end
  end

  namespace :users do
    resource :profile, only: [:show, :update], controller: "profile"
  end

  resource :avatars, only: [:destroy]

  resource :settings, only: [:show, :update], controller: "settings" do
    resource :billing_information, only: [:show, :edit, :update], controller: "settings/billing_information"
    resource :subscription, only: [:new], controller: "settings/subscriptions"
    resources :users, controller: "settings/users", except: [:destroy] do
      member do
        post :toggle_status
      end
    end
  end

  namespace :webhooks do
    resource :stripe, only: [:create], controller: "stripe"
  end

  root "dashboard#show"
end
