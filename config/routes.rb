Rails.application.routes.draw do
  namespace :api do
    post 'onboarding/signup', to: 'onboarding#signup'
    post 'auth/login', to: 'auth#login'

    resource :users, only: [] do
      get :me, on: :collection
    end

    resources :users, only: [:index, :show, :create]
    resources :drivers, only: [:create] do
      member do
        patch :approve
      end
    end

    resources :vehicles, only: [:index, :show, :create, :update, :destroy]
    resources :routes, only: [:index, :create]
    resources :shift_assignments, only: [:index, :show, :create, :update, :destroy]

    resources :trips, only: [:index, :show, :create] do
      member do
        patch :end_trip
        get :summary
      end
      collection do
        get :monthly_summary
      end
    end

    resources :trips do
      resources :fuel_records, only: [:index, :create]
      resources :expense_records, only: [:index, :create]
    end

    namespace :billing do
      get :invoice
      get :driver_statements
      get :company_summary
    end
  end
end
