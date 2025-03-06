Rails.application.routes.draw do
  resources :bill_orders

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
      resource :currencies do
        collection do
          get :get_currency
        end
        # get :get_currency

      end
      resources :payment_processors do
        collection do
          post :payment_order
          post :verify_meter
          post :process_payment
          get :get_balance
          get :get_price_list
        end
        member do
          get :approve_data
          get :confirm_payment
          get :query_transaction

        end

      end
      resources :card_tokens do
        collection do
          get :user
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

      resources :bill_orders do
        collection do
          get :user
        end
      end

      resources :paystack_transactions do
        collection do
          post :initialize_payment
          get :verify_payment
          get :list_payments
        end

        member do
          get :fetch_payment
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
          patch  :update_password
          get :password_reset
        end

      end

      resources :statistics





    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
