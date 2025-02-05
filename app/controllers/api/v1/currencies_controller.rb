class Api::V1::CurrenciesController < ApplicationController
    skip_before_action :authenticate_user!
    # before_action :set_wallet, only: %i[ show update destroy ]

    def get_currency

        from = params[:from_curr]
        to = params[:to_curr]
        amount = params[:amount]

        conversion = CurrencyService.new(from, to ,amount)
        response = conversion.get_conversion


        if response[:status] == "error"
        render json: {message: response[:message] }

        else
            #    binding.b
            render json: {data: response[:response] }

        end
    end


end