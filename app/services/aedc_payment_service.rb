require 'uri'
class AedcPaymentService
    include HTTParty

    base_uri Rails.env.production? ? 'https://vtpass.com/api' : 'https://sandbox.vtpass.com/api'


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


        def verify_meter(verify_processor_params)
            begin
            body = verify_processor_params.to_json
            response = self.class.post("/merchant-verify", headers: @get_headers, body: body  )

            if response.success?
                return response
            else
                raise "API Error: #{response.code} - #{response.body}"

            end
            rescue StandardError => e
                raise "API Error: #{e.message}"

            end

        end

        def pay_power(payment_processor_params)


            body = payment_processor_params.to_h



            begin

              response = self.class.post("/pay", headers: @post_headers, body: body)

              if response.success?
                return response
              else
                return raise "API Error #{response.body} - #{response.code}"

              end


            rescue StandardError => e
                raise "API Error: #{e.message}"

            end

        end


    end


end