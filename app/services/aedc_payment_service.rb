require 'uri'
class AedcPaymentService
    include HTTParty

    # base_uri Rails.env.production? ? 'https://vtpass.com/api' : 'https://sandbox.vtpass.com/api'
    base_uri 'https://sandbox.vtpass.com/api'


    def initialize()
        api_key = "5abfd3634000545546e91094b1c1bc27"
        public_key ="PK_3319f11930fec21677595bdce2807c33fc2d0f84b0f"
        secret_key = "SK_14174fe2e55c6e8b115911f80d994e236774845c97c"

        @get_headers = {
            "api-key" =>  api_key,
            "public-key" => public_key
        }

        @post_headers = {
            "api-key" =>  api_key,
            "secret-key" => secret_key

        }

    end


    def process_payment(payment_processor_params)
            verify_meter_params= {
                type: payment_processor_params[:variation_code],
                billersCode: payment_processor_params[:billersCode],
                serviceID: payment_processor_params[:serviceID]
            }

            begin

          res = verify_meter(verify_meter_params)

          electric_bill_order = ElectricBillOrder.new(
            meter_number: res["content"]["MeterNumber"],
            meter_type: payment_processor_params[:variation_code],
            meter_address: res["content"]["Address"],
            customer_name: res["content"]["Customer_Name"],
            email: payment_processor_params[:email],
            amount: payment_processor_params[:amount],
            request_id: payment_processor_params[:request_id],
            phone: payment_processor_params[:phone],
            serviceID: payment_processor_params[:serviceID],
            )

            # binding.b

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
        begin
            body = verify_processor_params
            response = self.class.post("/merchant-verify", headers: @post_headers, body: body  )

            if response.success? && response["content"]["error"].present?
            raise response["content"]["error"]

        else
             return response

        end
        rescue StandardError => e
            raise e.message
            # return {message: "#{e.message}"}


        end

    end

    def pay_power(electric_bill_order)
        body = {

        billersCode: electric_bill_order["meter_number"],
        amount: electric_bill_order["amount"],
        request_id: electric_bill_order["request_id"],
        variation_code: electric_bill_order["meter_type"],
        phone: electric_bill_order["phone"],
        serviceID: electric_bill_order["serviceID"],
        email: electric_bill_order["email"]
        }



            begin

              response = self.class.post("/pay", headers: @post_headers, body: body)

              if response["code"] == "000" && response.success?

                electric_bill_order.update(status: "completed", token: response["Token"], transaction_id: response["content"]["transactions"]["transactionId"])
                return { response: electric_bill_order, status: "success" }
             else
                    return {response: response["response_description"], status: "error"}
            end


            rescue StandardError => e
                return {response: "#{e.message}", status: "error"}

            end



    end


end