Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    post "login", to: "auth#login"
    post "drivers/register", to: "drivers#create"
    patch "drivers/:id/approve", to: "drivers#approve"
    resources :vehicles
    resources :trips do
      member do
        patch :end_trip
        get :summary
      end
    end
    resources :shifts do
      member do
        patch :end_shift
      end
    end
    resources :fuel_records, only: [:create, :index]
    resources :routes
    resources :shift_assignments
    resources :expense_records, only: [:create, :index]
    resources :users, only: [:create, :index, :show]
  end
end
