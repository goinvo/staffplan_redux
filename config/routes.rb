Rails.application.routes.draw do

  devise_for :users

  resources :invites, only: :index, controller: 'user_invites' do
    member do
      put :accept
      put :decline
    end
  end

  resources :staffplans do
    collection do
      get :date_range
    end
  end

  resources :companies do
    resources :invites, except: [:show, :edit, :update]
  end

  resources :clients do
    resources :projects, only: [:show, :new, :create]
  end

  resources :projects, except: [:show, :new, :create] do
    resources :assignments, only: [:new, :create]
  end

  resources :assignments

  resources :work_weeks

  resources :current_companies, only: :update

  root 'staffplans#index'
end
