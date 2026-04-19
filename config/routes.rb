Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "opportunities#index"

  resource :session, only: %i[ create destroy ]
  get "signin", to: "sessions#new", as: :signin

  resources :users, only: %i[ create edit update ]
  get "signup", to: "users#new", as: :signup
  resources :skills, only: %i[ create destroy ]
  resources :projects
  resources :opportunities, only: %i[ show new create ] do
    scope module: :opportunities do
      resource :download, only: :show
    end
  end
  get "opportunities", to: "opportunities#list", as: :opportunities_list

  get "carreer", to: "users#show", as: :carreer
end
