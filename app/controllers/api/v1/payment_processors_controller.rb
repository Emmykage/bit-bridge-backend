class Api::V1:: PaymentProcessorsController < ApplicationController
    before_action :set_electric_bill_order, only: %i[ show approve_payment ]

    def verify_meter
        service = AedcPaymentService.new
        service.verify_meter(verify_processor_params)

    end

    def show
        render json:{data:  @electric_bill_order}
    end

    def approve_payment
        service = AedcPaymentService.new
        service_response = service.pay_power(@electric_bill_order)
        if service_response[:status] == "success"
            render json: { success: true, data: service_response[:response], message: "payment confirmed" }, status: :ok
        else
            render json: { success: false, message: service_response[:response] }, status: :unprocessable_entity
        end


    end


    # def payment_order
    #     service = AedcPaymentService.new
    #     response =   service.pay_power(payment_processor_params)


    #     # render json: @provision.errors, status: :ok


    #     render json: {data: response}

    # end

    def process_payment
        service = AedcPaymentService.new
        service_response = service.process_payment(payment_processor_params)

        if service_response[:status] == "success"

            render json: {data: service_response[:response], message: "Transaction initiated"}, status: :created
        else
            render json: { message: service_response[:response]}, status: :unprocessable_entity
        end


    end



    def payment_processor_params
        params.permit(:billersCode, :amount, :request_id, :variation_code, :phone, :serviceID, :email, :status )

    end

    def verify_processor_params
        params.permit(:billersCode, :serviceID, :type )

    end


    def set_electric_bill_order
        @electric_bill_order = ElectricBillOrder.find(params[:id])
      end



end