require 'uri'
class BuyPowerPaymentService
    include HTTParty

    # base_uri Rails.env.production? ? 'https://vtpass.com/api' : 'https://sandbox.vtpass.com/api'
    base_uri 'https://idev.buypower.ng/v2'


    def initialize()
        api_key = "5abfd3634000545546e91094b1c1bc27"
        public_key ="PK_3319f11930fec21677595bdce2807c33fc2d0f84b0f"
        secret_key = "SK_14174fe2e55c6e8b115911f80d994e236774845c97c"
        token = "7883e2ec127225f478279f0cb848e3551eaaa99d484ec39cf0b77a9ccf1d9d0d"

        @get_headers = {
            "Authorization" =>  "Bearer #{token}"

        }

        @post_headers = {
             "Authorization" =>  "Bearer #{token}"
        }

    end


    def process_payment(current_user, payment_processor_params)

            begin

            res = verify_meter(payment_processor_params)

            bill_order = current_user.bill_orders.new(
            meter_number: payment_processor_params[:billersCode],
            meter_type: res["vendType"],
            address: res["address"],
            name: res["name"],
            tariff_class: payment_processor_params[:tariff_class],
            service_type: payment_processor_params[:service_type],
            email: payment_processor_params[:email],
            amount: payment_processor_params[:amount],
            phone: payment_processor_params[:phone],
            biller: payment_processor_params[:biller],
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

    def pay_power(electric_bill_order)
        body = {

        meter: electric_bill_order["meter_number"],
        amount: electric_bill_order["amount"],
        orderId: electric_bill_order["id"],
        vendType: electric_bill_order["meter_type"],
        phone: electric_bill_order["phone"],
        disco: electric_bill_order["biller"],
        vertical: electric_bill_order["service_type"],
        paymentType: electric_bill_order["payment_type"],
        name: electric_bill_order["name"],
        email: electric_bill_order["email"]
        }


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
        }


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

    def confirm_subscription(electric_bill_order)

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
        }


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



end