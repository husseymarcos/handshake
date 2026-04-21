Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "opportunities#new"

  resource :session, only: %i[ create destroy ]
  get "signin", to: "sessions#new"

  resources :professionals, only: %i[ create edit update ]
  get "signup", to: "professionals#new"
  get "career", to: "professionals#show"
  get "settings", to: "professionals#edit"

  resources :capabilities, only: %i[ create destroy ]
  resources :experiences

  resources :opportunities, only: %i[ index show new create ] do
    scope module: :opportunities do
      resource :download, only: :show
    end
  end
end
