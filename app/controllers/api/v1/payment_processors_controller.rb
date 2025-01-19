class Api::V1:: PaymentProcessorsController < ApplicationController

    def verify_meter
        service = AedcPaymentService.new
        service.verify_meter(verify_processor_params)

    end

    def payment_order
        service = AedcPaymentService.new
        response =   service.pay_power(payment_processor_params)

        binding.b

        # render json: @provision.errors, status: :ok


        render json: {data: response}

    end


    def payment_processor_params
        params.permit(:billersCode, :amount, :request_id, :variation_code, :phone, :serviceID, :email )

    end

    def verify_processor_params
        params.permit(:billersCode, :serviceID, :type )

    end



end