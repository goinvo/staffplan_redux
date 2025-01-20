require 'sidekiq/web'

Rails.application.routes.draw do
  # TODO: some kind of auth here
  mount Sidekiq::Web => '/sidekiq', constraints: lambda { |request|
    user = Passwordless::Session.find_by(id: request.session[:"passwordless_session_id--user"])&.authenticatable

    user && Prefab.enabled?("super-admin", { user: { email: user&.email }})
  }

  mount MissionControl::Jobs::Engine, at: "/jobs", constraints: lambda { |request|
    if Rails.env.development?
      true
    else
      user = Passwordless::Session.find_by(id: request.session[:"passwordless_session_id--user"])&.authenticatable

      user && Prefab.enabled?("super-admin", { user: { email: user&.email }})
    end
  }

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql", constraints: lambda { |request|
    # only allow allowed users, otherwise 404
    user = Passwordless::Session.find_by(id: request.session[:"passwordless_session_id--user"])&.authenticatable

    Rails.env.development? ||
      # (user && Prefab.enabled?("graphiql-access", { user: { email: user&.email }}))
      false
  }

  post "/graphql", to: "graphql#execute"

  resources :registrations, only: [:new, :create] do
    member do
      get :register
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  passwordless_for :users, at: '/', as: :auth, controller: "sessions"

  resource :dashboard, only: [:show], controller: "dashboard" do
    collection do
      post :switch_account
    end
  end

  resource :avatars, only: [:destroy]

  resource :settings do
    resource :company, only: [:show, :update], controller: "settings/company"
    resource :billing_information, only: [:show, :edit, :update], controller: "settings/billing_information"
    resource :subscription, only: [:new], controller: "settings/subscriptions"
    resources :users, controller: "settings/users", except: [:destroy] do
      member do
        post :toggle_status
      end
    end
    resource :profile, only: [:show, :update], controller: "settings/profile"
  end

  namespace :webhooks do
    resource :stripe, only: [:create], controller: "stripe"
  end

  root "dashboard#show"
end
