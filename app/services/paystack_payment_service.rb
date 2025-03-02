require 'uri'
class PaystackPaymentService
    include HTTParty

    # base_uri Rails.env.production? ? 'https://vtpass.com/api' : 'https://sandbox.vtpass.com/api'
    base_uri "https://api.paystack.co"


    def initialize()
        api_key = ENV["API_KEY"]
        public_key = ENV["PUBLIC_KEY"]
        secret_key =  ENV["PAYSTACK_SECRET_KEY"]

        @get_headers = {
            "api-key" =>  api_key,
            "public-key" => public_key
        }

        @post_headers = {
            "api-key" =>  api_key,
            "Authorization" => "Bearer #{secret_key}",
            "Content-Type" => "application/json"

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
            meter_number: payment_processor_params[:billersCode],
            # meter_number: res["content"]["Meter_Number"] || res["content"]["MeterNumber"],
            meter_type: payment_processor_params[:variation_code],
            meter_address: res["content"]["Address"],
            customer_name: res["content"]["Customer_Name"],
            email: payment_processor_params[:email],
            amount: payment_processor_params[:amount],
            request_id: payment_processor_params[:request_id],
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



    def initialize_transaction(processor_params)

        begin
            body = processor_params.to_json
            response = self.class.post("/transaction/initialize", headers: @post_headers, body: body  )



            if response.success?
                return {response: response, status: true}
            else
                return {response: response, status: false}


        end
        rescue StandardError => e
            return {response: {message: "#{e.message}"}, status: false}
        end

    end

    def verify_transaction(reference)
            begin
              response = self.class.get("/transaction/verify/#{reference}", headers: @post_headers)
              if response.success?

                return {response: response, status: true}
                    else
                return {response: response, status: false}
            end


            rescue StandardError => e
                return {response: {message: "#{e.message}"}, status: false}
            end
    end

    def list_transactions
        begin
          response = self.class.get("/transaction/", headers: @post_headers)

          if response.success?
              return response
          else
            return {response: response, status: "error"}
        end


        rescue StandardError => e
            return {response: {message: "#{e.message}"}, status: false}
        end
end
def fetch_transaction(id)

    begin
      response = self.class.get("/transaction/#{id}", headers: @post_headers)

      if response.success?
          return {response: response, status: true}
      else
        return {response: response, status: false}
    end


    rescue StandardError => e
        return {response: {message: "#{e.message}"}, status: false}
    end
end


end