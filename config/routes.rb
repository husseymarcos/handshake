Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "opportunities#new"

  resource :session, only: %i[ create destroy ]
  get "signin", to: "sessions#new"

  resources :users, only: %i[ create edit update ]
  get "signup", to: "users#new"
  get "career", to: "users#show"
  get "settings", to: "users#edit"

  resources :skills, only: %i[ create destroy ]
  resources :projects

  resources :opportunities, only: %i[ index show new create ] do
    scope module: :opportunities do
      resource :download, only: :show
    end
  end
end
