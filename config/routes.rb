Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "job_applications#index"

  resource :session, only: %i[ new create destroy ]
  resources :users, only: %i[ new create show edit update ]
  resources :skills, only: %i[ create destroy ]
  resources :projects
  resources :job_applications, only: %i[ index show new create ] do
    scope module: :job_applications do
      resource :download, only: :show
    end
  end
end
