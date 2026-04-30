Rails.application.routes.draw do
  namespace :api do
    # Onboarding
    post "onboarding/signup", to: "onboarding#signup"

    # Auth
    post "auth/login", to: "auth#login"

    # Resources
    resources :users, only: [:index, :show, :create]
    resources :drivers, only: [:create] do
      member do
        patch :approve
      end
    end
    resources :vehicles
    resources :routes, only: [:index, :create]
    resources :shift_assignments, only: [:create]
    resources :trips, only: [:index, :show, :create] do
      member do
        patch :end_trip
        get :summary
      end
    end
    resources :expense_records, only: [:index, :create]
    resources :fuel_records, only: [:index, :create]
  end
end

