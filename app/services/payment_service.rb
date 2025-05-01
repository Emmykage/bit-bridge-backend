class PaymentService
    include HTTParty
    base_uri Rails.env.production? ? ENV["MONNIFY_BASE_URL_PROD"] : "https://sandbox.monnify.com"

    def initialize()

        secret_key = ENV["MONNIFY_SECRET_KEY"]
        api_key = ENV["MONNIFY_API_KEY"]
        account_no = ENV["MONNIFY_WALLET_ACCOUNT_NUMBER"]
        @contract_code = ENV["MONNIFY_CONTRACT_CODE"]


        # secret_key = "4J1X69XH1BT0Y85DJCE9HKDRDJL3LNDH"
        # api_key = "MK_TEST_CQV87G8H1W"
        # account_no = "3822733711"
        # @contract_code = "2301355481"



        encode_64 = Base64.strict_encode64("#{api_key}:#{secret_key}")

        @headers = {
            "Authorization": "Basic #{encode_64}",
            "Content-Type": "application/json"


        }

    end

    def authenticate_and_store

        begin


        response = self.class.post("/api/v1/auth/login", headers: @headers)

        if response.success?
          monifyToken =   MonifyToken.create(token: response["responseBody"]["accessToken"], expires_in: Time.current + response["responseBody"]["expiresIn"])
            if monifyToken.save
                return monifyToken

            else
                raise monifyToken.errors.full_messages.to_sentence
            end
        else
            raise response["responseMessage"] || "bad request"

        end

    rescue StandardError => e

        return {response: "#{e.message}", status: :bad_request}

        end
    end

    def get_token
      monify =  MonifyToken.first
      if monify.present? &&  monify.expires_in > Time.current
        return  monify.token
      end
        monify = authenticate_and_store


        if monify.is_a?(Hash) && monify[:status] == :bad_request
            raise "Token authentication failed: #{monify[:response]}"
        end

        monify.token

    end

    def init_transaction(record_params)
        begin

            headers = {
                "Authorization": "Bearer #{get_token}",
                "Content-Type": "application/json"
            }

           body = {
                "amount": record_params[:amount],
                "customerName": record_params[:customer_name] || record_params[:name],
                "customerEmail": record_params[:email],
                "paymentReference": (record_params[:type].present? && record_params[:type] == "bills") ? "bbg-#{Time.now.to_i}"  : "fbg-#{Time.now.to_i}",
                "paymentDescription": record_params[:description],
                "currencyCode": "NGN",
                "contractCode": @contract_code,
                "redirectUrl": record_params[:redirect_url] || "https://bitbridgeglobal.com/dashboard/transaction/confirm",
                "paymentMethods":["CARD","ACCOUNT_TRANSFER"],
                "metadata": {
                    "name": record_params[:customer_name] || record_params[:name],
                    "paymentPurpose": record_params[:payment_purpose]
                }
            }.to_json


            response =  self.class.post("/api/v1/merchant/transactions/init-transaction", headers: headers, body: body )

            if response.success?
                return {response: response, status: :ok}
            else
                raise  response["responseMessage"]
            end
            rescue StandardError => e
                return {message: "#{e.message}", body: body}
            end
        end




end