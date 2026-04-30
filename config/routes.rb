Rails.application.routes.draw do
  namespace :api do
    # =========================
    # Onboarding
    # =========================
    post "onboarding/signup", to: "onboarding#signup"

    # =========================
    # Authentication
    # =========================
    post "auth/login", to: "auth#login"

    # =========================
    # Current User
    # =========================
    get "users/me", to: "users#me"

    # =========================
    # Core Resources
    # =========================
    resources :users, only: [:index, :show, :create]

    resources :drivers, only: [:create] do
      member do
        patch :approve
      end
    end

    resources :vehicles
    resources :routes, only: [:index, :create]
    resources :shift_assignments, only: [:create]

    # =========================
    # Trips + Nested Records
    # =========================
    resources :trips, only: [:index, :show, :create] do
      member do
        patch :end_trip
        get :summary
      end

      resources :fuel_records, only: [:index, :create]
      resources :expense_records, only: [:index, :create]
    end
  end
end

