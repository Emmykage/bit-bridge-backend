class Api::V1::CurrenciesController < ApplicationController
    skip_before_action :authenticate_user!
    # before_action :set_wallet, only: %i[ show update destroy ]

    def get_currency

        from = params[:from_curr]
        to = params[:to_curr]
        amount = params[:amount]

        conversion = CurrencyService.new(from, to)
        # response = conversion.get_conversion

        response = conversion.get_calculated_rate(amount)


        if response[:status] == "error"
        render json: {message: response[:message] }

        else
            render json: {data: response }

        end
    end


end