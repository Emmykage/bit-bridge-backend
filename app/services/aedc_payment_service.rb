require 'uri'
class AedcPaymentService
    include HTTParty

    # base_uri Rails.env.production? ? 'https://vtpass.com/api' : 'https://sandbox.vtpass.com/api'
    base_uri 'https://sandbox.vtpass.com/api'


    def initialize()
        api_key = "954f481698605fc0ffc27f24184928cd"
        public_key ="PK_4489272b5d44ab753dad880508a0b58e9d27b25d5a3"
        secret_key = "SK_548649124522dedaaa994acbb4779e91f9e8c7abf1a"

        @get_headers = {
            "api-key" =>  api_key,
            "public-key" => public_key
        }

        @post_headers = {
            "api-key" =>  api_key,
            "secret-key" => secret_key

        }


        def process_payment(payment_processor_params)
            verify_meter_params= {
                type: payment_processor_params[:variation_code],
                billersCode: payment_processor_params[:billersCode],
                serviceID: payment_processor_params[:serviceID]
            }

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
            request_id: payment_processor_params[:request_id],
            )
            electric_bill_order.save

            electric_bill_order


        end



        def verify_meter(verify_processor_params)
            begin
            body = verify_processor_params
            response = self.class.post("/merchant-verify", headers: @post_headers, body: body  )

            if response.success?
                return response
            else
                raise "API Error: #{response.code} - #{response.body}"

            end
            rescue StandardError => e
                raise "API Error: #{e.message}"

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

        # binding.b

            begin

              response = self.class.post("/pay", headers: @post_headers, body: body)

              if response.success?
                electric_bill_order.update(status: "completed", token: response["Token"], transaction_id: response["content"]["transactions"]["transactionId"])
                return { response: electric_bill_order }
            else
                return raise "API Error #{response.body} - #{response.code}"

              end


            rescue StandardError => e
                raise "API Error: #{e.message}"

            end

        end


    end


end