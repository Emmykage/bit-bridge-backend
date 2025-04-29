class PaymentService
    include HTTParty
    base_uri "https://sandbox.monnify.com"

    def initialize()

        secret_key = ENV["MONNIFY_SECRET_KEY"]
        api_key = ENV["MONNIFY_API_KEY"]
        account_no = ENV["MONNIFY_WALLET_ACCOUNT_NUMBER"]
        contract_code = ENV["MONNIFY_CONTRACT_CODE"]
        encode_64 = Base64.strict_encode64("#{api_key}:#{secret_key}")

        @headers = {
            "Authorization": "Basic #{encode_64}",
            "Content-Type": "application/json"


        }

    end

    def authenticate_and_store

        begin


        response = self.class.post("/api/v1/auth/login", headers: @headers)
        # binding.b

        if response.success?
          monifyToken =   MonifyToken.create(token: response["responseBody"]["accessToken"], expires_in: Time.current + response["responseBody"]["expiresIn"])
          if monifyToken.save
           return monifyToken

            else
                raise monifyToken.errors.full_messages.to_sentence

            end


        else
            raise response["responseMessage"]

        end

        rescue StandardError => e

            return {response: "#{e.message}", status: :bad_request}

         end
    end

    def get_token
      monify =  MonifyToken.last
      if monify.present? &&  monify.expires_in > Time.current
        monify.token
      else
        monify = authenticate_and_store
        monify.token
      end
    end

    def init_transaction(transaction_record_params)

        headers = {
            "Authorization": "Bearer #{get_token}",
            "Content-Type": "application/json"
        }

       body = {
            "amount": transaction_record_params[:amount],
            "customerName": transaction_record_params[:customer_name],
            "customerEmail": transaction_record_params[:email],
            "paymentReference": "bbg-#{Time.now.to_i}",
            "paymentDescription": transaction_record_params[:description],
            "currencyCode": "NGN",
            "contractCode": ENV["MONNIFY_CONTRACT_CODE"],
            "redirectUrl": transaction_record_params[:redirect_url] || "https://bitbridgeglobal.com/dashboard/transaction/confirm",
            "paymentMethods":["CARD","ACCOUNT_TRANSFER"]
        }.to_json

      response =   self.class.post("/api/v1/merchant/transactions/init-transaction", headers: headers, body: body )

      if response.success?
       return {response: response, status: :ok}
      else
        return {message: response["responseMessage"], status: :bad_request}

      end
    end




end