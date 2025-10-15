# frozen_string_literal: true

Rails.application.routes.draw do
  resources :bank_transactions
  resources :commissions
  resources :bill_orders

  get 'users/index'
  get 'users/update'
  get 'users/delete'
  # devise_for :users
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  }, controllers: {
    sessions: 'users/sessions',
    confirmations: 'users/confirmations',
    registrations: 'users/registrations'
  }

  devise_scope :user do
    post 'refresh', to: 'users/sessions#refresh_token'
  end

  get 'tokens', to: 'api/v1/tokens#token'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # get "payment-processor/get-balance", to: "payment_processors#get_balance"
      # Define your API routes here

      post 'monnify/webhook', to: 'webhooks#monnify'
      # resources :webhooks do
      #   collection do
      #     post :monnify
      #   end

      # end
      resources :refresh do
        collection do
          get :refresh
        end
      end
      resources :accounts do
        collection do
          post :verify_kyc
          get :get_account_number
          get :user_accounts
        end
      end
      resources :transaction_records
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
          get :update_status
          get :get_ref_order

          get :confirm_payment
          get :query_transaction
          get :repurchase
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
          post :initialize_transaction
          post :create_user
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
          get :user_recent
        end

        member do
          get :initialize_confirm_payment
          patch :initialize_confirm_payment
          patch :confirm_bill_payment
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
          get :user
        end
      end
      resources :users do
        collection do
          get :user_profile
          patch :user_update
          patch :update_password
          patch :user_password_update
          get :password_reset
          patch :activate_user
          get :resend_confirmation_token
        end
      end

      resources :statistics
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
