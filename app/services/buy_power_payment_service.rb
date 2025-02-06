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


    def process_payment(payment_processor_params)

            begin

            res = verify_meter(payment_processor_params)


            # binding.b
          electric_bill_order = ElectricBillOrder.new(
            meter_number: payment_processor_params[:billersCode],
            meter_type: payment_processor_params[:variation_code],
            meter_address: res["address"],
            customer_name: res["name"],
            email: payment_processor_params[:email],
            amount: payment_processor_params[:amount],
            request_id: res["orderId"],
            phone: payment_processor_params[:phone],
            serviceID: payment_processor_params[:serviceID],
            )


            if electric_bill_order.save
                return {response: electric_bill_order, status: "success"}
            else
                return {response:  electric_bill_order.errors, status: "error"}
            end

            rescue StandardError => e
                return {response: "#{e.message}", status: "error"}

            end




    end



    def verify_meter(verify_processor_params)

        meter_no = verify_processor_params[:billersCode]
        biller = verify_processor_params[:serviceID]
        type = verify_processor_params[:variation_code]
        begin
            body = verify_processor_params

            response = self.class.get("/check/meter?meter=#{meter_no}&disco=#{biller}&vendType=#{type}&vertical=ELECTRICITY&orderId=false", headers: @get_headers )



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
        disco: electric_bill_order["serviceID"],
        vertical: "ELECTRICITY"
        paymentType: "online"
        # tariffClass: ""
        email: electric_bill_order["email"]
        }



            begin

              response = self.class.post("/pay", headers: @post_headers, body: body)

              if response.success?

                electric_bill_order.update(status: "completed", token: response["purchased_code"], transaction_id: response["content"]["transactions"]["transactionId"])
                return { response: electric_bill_order, status: "success" }
             else
                    return {response: response["response_description"], status: "error"}
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
        phone: electric_bill_order["phone"],
        disco: electric_bill_order["serviceID"],
        vertical: "ELECTRICITY"
        paymentType: "online"
        tariffClass: ""
        email: electric_bill_order["email"]
        }



            begin

              response = self.class.post("/pay", headers: @post_headers, body: body)

              if response["code"] == "000" && response.success?

                electric_bill_order.update(status: "completed", token: response["purchased_code"], transaction_id: response["content"]["transactions"]["transactionId"])
                return { response: electric_bill_order, status: "success" }
             else
                    return {response: response["response_description"], status: "error"}
            end


            rescue StandardError => e
                return {response: "#{e.message}", status: "error"}

            end



    end


end