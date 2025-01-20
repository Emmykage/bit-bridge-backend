Rails.application.routes.draw do

  get 'users/index'
  get 'users/update'
  get 'users/delete'
  # devise_for :users
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout",
    registration: "signup"
  }, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do

      # get "payment-processor/get-balance", to: "payment_processors#get_balance"
      # Define your API routes here
      resources :payment_processors do
        collection do
          post :payment_order
          post :verify_meter
          post :process_payment
        end
        member do
          patch :approve_payment
        end

      end

      resources :products
      resources :provisions
      resources :gift_cards
      resources :transactions do
        collection do
        get :user
        end
      end
      resources :wallets do
        collection do
          get :user

        end

      end

      resources :order_items
      resources :order_details do
        collection do
          get :user
        end
      end

      resources :user_profiles do
        collection do
        get  :user
        end
      end
      resources :users do
        collection do
        get  :user_profile
        end
      end


    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
