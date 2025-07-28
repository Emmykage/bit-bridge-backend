require 'uri'
class BuyPowerPaymentService
    include HTTParty

    base_uri Rails.env.production? ? "https://api.buypower.ng/v2" : 'https://idev.buypower.ng/v2'

    def initialize()

        secret_token_dev  =  ENV['SECRET_TOKEN_DEV']
        secret_token_prod  = ENV['SECRET_TOKEN_PROD']
        token =  Rails.env.production? ? secret_token_prod  : secret_token_dev

        @get_headers = {
            "Authorization" =>  "Bearer #{token}"

        }

        @post_headers = {
             "Authorization" =>  "Bearer #{token}"
        }

    end


    def process_payment(current_user, payment_processor_params)

            begin
                res = nil

                unless payment_processor_params[:skip] === true

                    res = verify_meter(payment_processor_params)

                end

            bill_order = current_user&.bill_orders&.new(
            meter_number: payment_processor_params[:billersCode],
            meter_type: res&.dig("vendType") || "PREPAID",
            address: res&.dig("address") || payment_processor_params[:billersCode],
            name: res&.dig("name") || payment_processor_params[:billersCode],
            tariff_class: payment_processor_params[:tariff_class],
            service_type: payment_processor_params[:service_type],
            email: payment_processor_params[:email],
            amount: payment_processor_params[:amount],
            phone: payment_processor_params[:phone],
            biller: payment_processor_params[:biller],
            description:  payment_processor_params[:description],
            demand_category: res&.dig("demandCategory")

            ) || BillOrder.new(
                meter_number: payment_processor_params[:billersCode],
                meter_type: res&.dig("vendType") || "PREPAID",
                address: res&.dig("address") || payment_processor_params[:billersCode],
                name: res&.dig("name") || payment_processor_params[:billersCode],
                tariff_class: payment_processor_params[:tariff_class],
                service_type: payment_processor_params[:service_type],
                email: payment_processor_params[:email],
                amount: payment_processor_params[:amount],
                phone: payment_processor_params[:phone],
                biller: payment_processor_params[:biller],
                description:  payment_processor_params[:description],
                demand_category: res&.dig("demandCategory")

              )




            if bill_order.save

                return {response: bill_order, status: "success"}
            else
                raise bill_order.errors.full_messages.to_sentence
            end

            rescue StandardError => e

                return {response: "#{e.message}", status: "error"}

            end




    end



    def verify_meter(verify_processor_params)


        meter_number = verify_processor_params[:billersCode]
        biller = verify_processor_params[:biller]
        meter_type = verify_processor_params[:meter_type]
        service_type = verify_processor_params[:service_type].upcase



        begin
            body = verify_processor_params

            response = self.class.get("/check/meter?meter=#{meter_number}&disco=#{biller}&vendType=#{meter_type}&vertical=#{service_type}&orderId=false", headers: @get_headers )


            if !response.success?
            raise response["message"]

        else

             return response

        end
        rescue StandardError => e

            raise e.message


        end

    end




    def pay_data(electric_bill_order)

        body = {

        meter: electric_bill_order["meter_number"],
        amount: electric_bill_order["amount"],
        orderId: electric_bill_order["id"],
        vendType: electric_bill_order["meter_type"],
        phone: electric_bill_order["meter_number"],
        disco: electric_bill_order["biller"],
        vertical: electric_bill_order["service_type"],
        paymentType: electric_bill_order["payment_type"],
        name: electric_bill_order["name"],
        email: electric_bill_order["email"],
        tariffClass: electric_bill_order["tariff_class"]
    }.transform_values {|v| v.is_a?(String) ? v.strip : v }


            begin

              response = self.class.post("/vend", headers: @post_headers, body: body)

              if response.success?

                electric_bill_order.update(status: "completed", units: response["data"]["units"],  token: response["data"]["token"], transaction_id: response["data"]["id"])
                return { response: electric_bill_order, status: "success" }
             else

                    raise response["message"]
            end


            rescue StandardError => e
                return {response: "#{e.message}", status: "error"}

            end



    end

    def confirm_subscription(electric_bill_order, payment_method = "wallet")

        body = {
        meter: electric_bill_order["meter_number"],
        amount: electric_bill_order["amount"],
        orderId: electric_bill_order["id"],
        vendType: electric_bill_order["meter_type"],
        phone: electric_bill_order["phone"] || electric_bill_order["service_type"] == "TV"   ? "07064334160" : electric_bill_order["meter_number"],
        disco: electric_bill_order["biller"],
        vertical: electric_bill_order["service_type"],
        paymentType: electric_bill_order["payment_type"],
        name: electric_bill_order["name"],
        email: electric_bill_order["email"],
        tariffClass: electric_bill_order["tariff_class"]
     }.transform_values {|v| v.is_a?(String) ? v.strip : v }


            begin
                response = nil
                if payment_method == "wallet"
                    unless electric_bill_order.user&.active
                         raise 'user is inactive'
                    end

                    #update the order before transaction so you can update after transaction then check the previous transaction to ensure none was made at the same time

                  if  electric_bill_order.user.wallet.balance >= electric_bill_order[:usd_amount]
                    # Timeout.timeout(120) do
                        response = self.class.post("/vend", headers: @post_headers, body: body)
                    # end
                    else
                    raise 'Insufficient funds'

                 end

                elsif payment_method == "card"
                        Timeout.timeout(120) do
                        response = self.class.post("/vend", headers: @post_headers, body: body)
                    end
                else
                    raise "no payment method selected"


                end

                   if response.success?
                    electric_bill_order.update(status: "completed", payment_method: payment_method, units: response["data"]["units"],  token: response["data"]["token"], transaction_id: response["data"]["id"])
                    return { response: electric_bill_order, status: "success" }

                 else
                    raise response["message"]

                 end

                rescue Timeout::Error
                    electric_bill_order.update(status: "timedout")
                 {response: "The request timed out. Please try again", code: 504, status: "TIMEOUT"}


            rescue StandardError => e
                return {response: "#{e.message}", status: "error"}

            end



    end

    def confirm_subscription_monnify(electric_bill_order, payment_method = "wallet")

        payment_service = PaymentService.new
        response_service = payment_service.init_transaction(electric_bill_order)


            return response_service

        body = {
        meter: electric_bill_order["meter_number"],
        amount: electric_bill_order["amount"],
        orderId: electric_bill_order["id"],
        vendType: electric_bill_order["meter_type"],
        phone: electric_bill_order["service_type"] === "ELECTRICITY" ? electric_bill_order["phone"] :  electric_bill_order["meter_number"],
        disco: electric_bill_order["biller"],
        vertical: electric_bill_order["service_type"],
        paymentType: electric_bill_order["payment_type"],
        name: electric_bill_order["name"],
        email: electric_bill_order["email"],
        tariffClass: electric_bill_order["tariff_class"]
     }.transform_values {|v| v.is_a?(String) ? v.strip : v }


            begin
                response = nil
                if payment_method == "wallet"


                  if  electric_bill_order.user.wallet.balance > electric_bill_order[:usd_amount]
                    # Timeout.timeout(120) do
                        response = self.class.post("/vend", headers: @post_headers, body: body)
                    # end
                    else
                    raise 'Insufficient funds'

                 end

                elsif payment_method == "card"
                        Timeout.timeout(120) do
                        response = self.class.post("/vend", headers: @post_headers, body: body)
                    end
                else
                    raise "no payment method selected"


                end


                   if response.success?
                    electric_bill_order.update(status: "completed", payment_method: payment_method, units: response["data"]["units"],  token: response["data"]["token"], transaction_id: response["data"]["id"])
                    return { response: electric_bill_order, status: "success" }

                 else
                    raise response["message"]

                 end

                rescue Timeout::Error
                    electric_bill_order.update(status: "timedout")
                 {response: "The request timed out. Please try again", code: 504, status: "TIMEOUT"}


            rescue StandardError => e
                return {response: "#{e.message}", status: "error"}

            end



    end

    def repurchase_subscription(current_user, bill_order)

        begin
    electric_bill_order =  current_user.bill_orders.new(
            meter_number: bill_order[:meter_number],
            meter_type: bill_order [:meter_type],
            address: bill_order[:address],
            name:  bill_order[:name],
            tariff_class: bill_order[:tariff_class],
            service_type: bill_order[:service_type],
            email: bill_order[:email],
            amount: bill_order[:amount],
            phone: bill_order[:phone],
            biller: bill_order[:biller],
        )




        if electric_bill_order.save
            confirm_subscription(electric_bill_order)
        else
            raise bill_order.errors.full_messages.to_sentence
        end

        rescue StandardError => e
         return {response: "#{e.message}", status: "error"}
        end


    end




    def get_wallet_balance



            begin

              response = self.class.get("/wallet/balance", headers: @post_headers, body: body)

              if response.success?

                return { response: response, status: "success" }
             else
                raise response["message"]
            end


            rescue StandardError => e
                return {response: "#{e.message}", status: "error"}

            end



    end


    def get_list(service_type, provider)
        begin

            response = self.class.get("/tariff/?vertical=#{service_type}&provider=#{provider}", headers: @get_headers)
            if response.success?
            return { response: response["data"], status: "success"}

            else
                raise response["message"]

            end

        rescue StandardError => e
            return {response: "#{e.message}", status: "error"}
        end

    end

    def re_query(order_id)

        begin
        response = self.class.get("/transaction/#{order_id}", headers: @get_headers)

        if response.success?
           return {response: response, status: :ok}

        else
            raise response["message"]
        end

        rescue  StandardError => e
            return {response: "#{e.message}", status: :unprocessable_entity}

        end
    end




end