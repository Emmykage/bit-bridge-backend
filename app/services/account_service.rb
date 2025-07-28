class AccountService
    include HTTParty
    base_uri Rails.env.production? ? ENV["MONNIFY_BASE_URL_PROD"] : "https://sandbox.monnify.com"

    def initialize()

        secret_key =  ENV["MONNIFY_SECRET_KEY"]
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
          monifyToken = MonifyToken.create(token: response["responseBody"]["accessToken"], expires_in: Time.current + response["responseBody"]["expiresIn"])
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


    def headers
          headers = {
                "Authorization": "Bearer #{get_token}",
                "Content-Type": "application/json"
            }

    end

    def create_wallet_account(account_params)
             body= {
                # "accountReference": "ref-#{Time.now.to_i}",
                "accountReference": account_params[:user_id],
                "accountName": account_params[:account_name] || account_params[:customer_name],
                "currencyCode": account_params[:currency].upcase,
                "contractCode": @contract_code,
                "customerEmail": account_params[:email],
                "customerName": account_params[:customer_name] || account_params[:name],
                "bvn": account_params[:bvn],
                "getAllAvailableBanks":true,
                # "incomeSplitConfig": [
                #     {
                #         "subAccountCode": "MFY_SUB_322165393053",
                #         "feePercentage": 10.5,
                #         "splitAmount": 20,
                #         "feeBearer": true
                #     }
                # ]

            }.to_json

        begin

         response = self.class.post("/api/v1/bank-transfer/reserved-accounts", headers: headers, body: body)

            if response.success?
              account =  Account.new(account_number: response["responseBody"]["accountNumber"], bank_code: response["responseBody"]["bankCode"], account_name: response["responseBody"]["accountName"], vendor: account_params[:vendor] || "monnify", user_id: account_params[:user_id], bvn: account_params[:bvn], currency: account_params[:currency] || "NGN")
                if account.save
                return {response: response, status: :ok}
                else
                    raise account.errors.full_messages.to_sentence
                end
            else

                raise response["responseMessage"]
            end

        rescue StandardError => e
            return {message: "#{e.message}", body: body}
        end


    end
def get_wallet_account(accountReference)

        begin
         response = self.class.get("api/v1/bank-transfer/reserved-accounts/#{accountReference}", headers: headers,  body: body)
            if response.success?
                return {response: response, status: :ok}
            else
                raise response["responseMessage"]
            end

        rescue StandardError => e
            return {message: "#{e.message}", body: body}
        end


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
                "redirectUrl": record_params[:redirect_url] || "https://bitbridgeglobal.com/app-redirect",
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

                binding.b

                raise  response["responseMessage"]
            end
            rescue StandardError => e
                return {message: "#{e.message}", body: body}
            end
        end



        def get_reserved_account(account_reference)
                user = User.find_by(id: account_reference)

                return { message: "User not found" } unless user

                # Return early if user already has an account
                return { message: "Account already exists" } if user.account.present?

                begin
                    response = self.class.get(
                    "/api/v1/bank-transfer/reserved-accounts/#{account_reference}",
                    headers: headers
                    )

                    if response.success?
                    body = response["responseBody"]

                    account = Account.new(
                        account_number: body["accountNumber"],
                        bank_code: body["bankCode"],
                        account_name: body["accountName"],
                        vendor: "monnify",
                        user_id: user.id,
                        bvn: user.bvn,
                        currency: "NGN"
                    )

                    if account.save
                        return { response: response, status: :ok }
                    else
                        raise account.errors.full_messages.to_sentence
                    end
                    else
                    raise response["responseMessage"]
                    end
                rescue StandardError => e
                    return { message: e.message }
                end
                end






end