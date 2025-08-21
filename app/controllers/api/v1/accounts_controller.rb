# frozen_string_literal: true

module Api
  module V1
    class AccountsController < ApplicationController
      before_action :set_account, only: %i[show update destroy]

      def create
        unless current_user.user_profile.present?
          return render json: { message: 'User profile not found: please update your account' },
                        status: :unprocessable_entity
        end

        service = AccountService.new

        account_info = {
          vendor: account_params[:vendor] || 'monnify',
          bvn: account_params[:bvn],
          user_id: current_user.id,
          email: current_user.email,
          account_name: account_params[:account_name] || current_user.full_name,
          customer_name: current_user.full_name,
          currency: account_params[:currency] || 'NGN'
        }

        service_response = service.create_wallet_account(account_info)

        if service_response[:status] == :ok
          render json: { data: service_response[:response], message: 'Account created successfully' }, status: :ok
        else
          render json: { message: service_response[:message] }, status: :unprocessable_entity
        end
      end

      def show
        service = AccountService.new
        service_response = service.get_wallet_account(params[:id])

        if service_response[:status] == :ok
          render json: { data: service_response[:response] }, status: :ok
        else
          render json: { message: service_response[:message] }, status: :unprocessable_entity
        end
      end

      def get_account(user_id = null)
        accout_ref = params[:accountReference] || user_id


        service = AccountService.new
        service_response = service.get_reserved_account(accout_ref)

        if service_response[:status] == :ok
          render json: { data: service_response[:response] }, status: :ok
        else
          render json: { message: service_response[:message] }, status: :unprocessable_entity
        end
      end

      def set_account
        @accout = Account.find_by(id: params[:id])
        return if @accout

        render json: { message: 'Account not found' }, status: :not_found
      end

      def update
        service = AccountService.new
        service_response = service.update_wallet_account(params[:id], account_params)

        if service_response[:status] == :ok
          render json: { data: service_response[:response] }, status: :ok
        else
          render json: { message: service_response[:message] }, status: :unprocessable_entity
        end
      end

      def destroy
        service = AccountService.new
        service_response = service.delete_wallet_account(params[:id])

        if service_response[:status] == :ok
          render json: { message: 'Account deleted successfully' }, status: :ok
        else
          render json: { message: service_response[:message] }, status: :unprocessable_entity
        end
      end

      # POST /accounts
      def account_params
        params.require(:account).permit(:vendor, :bvn, :currency, :account_name)
      end
    end
  end
end
