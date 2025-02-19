class Api::V1::PaymentProcessorsController < ApplicationController
    before_action :set_bill_order, only: %i[ show approve_payment approve_data confirm_payment ]
    skip_before_action :authenticate_user!
    def verify_meter
        service = BuyPowerPaymentService.new
        service.verify_meter(verify_processor_params)

    end

    def show
        render json:{data:  @bill_order}
    end

    def approve_payment

        service = BuyPowerPaymentService.new
        service_response = service.pay_power(@bill_order)
        if service_response[:status] == "success"
            render json: { success: true, data: service_response[:response], message: "payment confirmed" }, status: :ok

        elsif service_response[:status] == "TIMEOUT"
            render json: { success: false, message: service_response[:response], code: 504 }, status: :request_timeout

        else
            render json: { success: false, message: service_response[:response] }, status: :unprocessable_entity
        end


    end

    def approve_data

        service = BuyPowerPaymentService.new
        service_response = service.pay_data(@bill_order)
        if service_response[:status] == "success"
            render json: { success: true, data: service_response[:response], message: "payment confirmed" }, status: :ok
        else
            render json: { success: false, message: service_response[:response] }, status: :unprocessable_entity
        end


    end

    def buy_data

        service = BuyPowerPaymentService.new
        service_response = service.pay_data(@bill_order)
        if service_response[:status] == "success"
            render json: { success: true, data: service_response[:response], message: "payment confirmed" }, status: :ok
        else
            render json: { success: false, message: service_response[:response] }, status: :unprocessable_entity
        end


    end

    def confirm_payment

        payment_method = params[:payment_method]

        service = BuyPowerPaymentService.new
        service_response = service.confirm_subscription(@bill_order, payment_method)
        if service_response[:status] == "success"
            render json: { success: true, data: service_response[:response], message: "payment confirmed" }, status: :ok
        else
            render json: { success: false, message: service_response[:response] }, status: :unprocessable_entity
        end


    end

    def process_payment


       service = BuyPowerPaymentService.new

        service_response = service.process_payment(current_user, payment_processor_params)

        if service_response[:status] == "success"

            render json: {data: service_response[:response], message: "Transaction initiated"}, status: :created
        else
            render json: { message: service_response[:response]}, status: :unprocessable_entity
        end


    end

    def get_balance

        service = BuyPowerPaymentService.new
        service_response.get_wallet_balance
        if service_response[:status] == "success"

            render json: {data: service_response[:response], message: "balance initiated"}, status: :ok
        else
            render json: { message: service_response[:response]}, status: :unprocessable_entity
        end

    end


    def get_price_list

        provider = params[:provider]
        service_type = params[:service_type]


        service = BuyPowerPaymentService.new
        service_response = service.get_list(service_type, provider)

        if service_response[:status] == "success"
            render json: {data: service_response[:response]}, status: :ok

        else

        render json: {message: service_response[:response]}, status: :unprocessable_entity
        end
    end


    def query_transaction
        id = params[:id]

        service =  BuyPowerPaymentService.new
        response_service = service.re_query(@bill_order[:id])
        if service_response[:status] == "success"
            render json: {data: service_response[:response]}, status: :ok

        else

        render json: {message: service_response[:response]}, status: :unprocessable_entity
        end
    end





    def payment_processor_params
        params.permit(:billersCode, :amount, :request_id, :meter_type, :phone, :biller, :email, :status , :tariff_class, :service_type)

    end

    def verify_processor_params
        params.permit(:billersCode, :serviceID, :type )

    end



    def set_bill_order
        @bill_order = BillOrder.find_by(id: params[:id])


        unless  @bill_order.present?
            render json: {message: "Not found"}, status: :unprocessable_entity
        end

      end



end