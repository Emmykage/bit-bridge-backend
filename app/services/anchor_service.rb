class AnchorService
    include HTTParty

    base_uri = "https://api.sandbox.getanchor.co/api/v1/"
    header_api_key =  ENV['ANCHOR_API_KEY'] || '9P6wC.4aed16aee26886c2480fbe21d174d2a1973dddaa3d3cac7d5b8908b4e24999d841b8491ff77c8f6a6d9a278483363a2312aa'
    def initialize
        @headers = {
            "x-anchor-key": header_api_key,
            "Content-Type": 'application/json'
        }
    end

    def create_individual_account(user_data)

        # user_data => {first_name:, last_name:, id:, email:, postal_code:,  bvn:, city:, dob:, phone_number:, address_line1:}
        first_name     = user_data[:first_name]
        last_name      = user_data[:last_name]
        id             = user_data[:id]
        email          = user_data[:email]
        postal_code    = user_data[:postal_code]
        bvn            = user_data[:bvn]
        city           = user_data[:city]
        state          = user_data[:state]
        dob            = user_data[:dob]
        phone_number   = user_data[:phone_number]
        address_line1  = user_data[:address_line1]

           body ={ "data": {
                type: "individualCustomer",
                attributes: {
                    fullName: {
                    "firstName": first_name,
                    "lastName": last_name
                },
                address: {
                    addressLine1: address_line1,
                    city: city,
                    state: state,
                    country: "NG",
                    postalCode: postal_code
                },
                email: email,
                phoneNumber: phone_number,
                metadata: {
                    my_customerID: id
                }
            }
        }}.to_json


        begin
            response = self.class.post("/customers", headers: @headers, body: body)


            if response.success?
                account_id = response["data"]["id"]
                user_data = user_data.merge(account_id: account_id)
                new_Account = Account.create(user_data)
                if new_Account.persisted?
                    return {response: response["data"], status: :ok}
                else
                    raise new_Account.errors.full_messages.to_sentence || 'bad request'
                end
            else
                raise response['message'] || 'bad request'
            end
            rescue StandardError => e
            { response: e.message || 'bad request', status: :bad_request }


        end
    end

    def user_kyc_verification(kyc_data, account)
        kyc_data => {bvn:, dob:, gender:}
        id = account.account_id
        body = {
          "data": {
                "type": "Verification",
                "attributes": {
                "level": "TIER_1",
                "level1": {
                    "bvn": bvn,
                    "dateOfBirth": dob,
                    "gender": gender
                }
                }
            }
        }.to_json
    begin

        response = self.class.post("/customers/#{id}/verification/individual", headers: @headers, body: body)
        if response.success?
            message = response&.dig("data", "message")
            raise "account  not found"  unless updatedAccount
               unless account.update(status: "verifying", dob: dob, bvn: bvn, gender: gender)
                raise account.errors.full_messages.to_sentence || 'bad request'
               end
            return {response: response["data"], message: message, status: :ok}
        else
        raise response['message'] || 'bad request'
        end
        rescue StandardError => e
        { message: e.message || 'bad request', status: :bad_request }

    end
end


def create_account_number(productType = "SAVINGS", type= :individual,  account)

    account_type = {:individual => "IndividualCustomer", :corporate => "CorporateCustomer"}
    body = {
        "data": {
            "type": "DepositAccount",
            "attributes": {
            "productName": productType
            },
            "relationships": {
            "customer": {
                "data": {
                "id": id,
                "type": account_type[type]
                }
            }
            }
        }
    }.to_json

        begin
            unless account_type.key?(type)
                raise "Invalid account type, Must be one of #{account_type.keys.join(", ")}"
            end

            response = self.class.post("/deposit-accounts", headers: @headers, body: body)
            account_number = response&.dig("data", "attributes", "bank", "accountNumber")
            bank_name = response&.dig("data", "attributes", "bank", "accountName")
        if response.success?
           unless account.update(account_number: account_number, account_type:  account_type[type], staus: "completed", active: true, bank_name: bank_name)

            account.errors.full_messages.to_sentence || 'bad request'
           end

         return   {response: response["data"], status: :ok}
        else
            raise response['message'] || 'bad request'
        end
        rescue StandardError => e
            return { response: e.message.to_s || 'bad request', status: :bad_request }

        end

end


def inboundDepositedFund(inboundTransferId)

    begin
        response = self.class.get("/inbound-transfers/#{inboundTransferId}", headers: @headers)
        return response if response.success?
        raise response['message'] || 'bad request'

    rescue StandardError => e
        return e.message.to_s || 'bad request'
    end

end

end