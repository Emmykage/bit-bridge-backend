# frozen_string_literal: true

class AnchorService
  include HTTParty

  base_uri ENV['DEV_ANCHOR_BASE_URL'] || 'https://api.sandbox.getanchor.co/'
  def initialize
    header_api_key = ENV['DEV_ANCHOR_API_KEY'] || '9P6wC.4aed16aee26886c2480fbe21d174d2a1973dddaa3d3cac7d5b8908b4e24999d841b8491ff77c8f6a6d9a278483363a2312aa'

    @headers = {
      'x-anchor-key' => header_api_key,
      'Content-Type' => 'application/json'
    }
  end

  def create_individual_account(user_data)
    # Expected user_data:
    # { first_name:, last_name:, id:, email:, postal_code:, bvn:, city:, state:, dob:, phone_number:, address_line1: }

    first_name = user_data[:first_name]
    last_name    = user_data[:last_name]
    id           = user_data[:user_id]
    email = user_data[:email]
    postal_code = user_data[:postal_code]
    user_data[:bvn]
    city         = user_data[:city]
    state        = user_data[:state]
    user_data[:dob]
    phone_number = user_data[:phone_number]
    address      = user_data[:address]

    body = {
      data: {
        type: 'IndividualCustomer',
        attributes: {
          fullName: {
            firstName: first_name,
            lastName: last_name
          },
          address: {
            addressLine_1: address,
            addressLine_2: address,
            city: city,
            state: state,
            country: 'NG',
            postalCode: postal_code
          },
          email: email,
          phoneNumber: phone_number,
          metadata: {
            my_customerID: id
          }
        }
      }
    }.to_json

    begin
      response = self.class.post('/api/v1/customers', headers: @headers, body: body)

      if response.success?
        account_id = response['data']['id']
        new_account = store_account_details(account_id, user_data)
        { response: new_account, status: :ok }

      else
        error_title = response.dig('errors', 0, 'detail') || 'bad request'
        raise error_title
      end
    rescue StandardError => e
      { message: e.message || 'bad request', status: :bad_request }
    end
  end

  def user_kyc_verification(kyc_data, account)
    bvn = kyc_data[:bvn] || account[:bvn]
    dob = kyc_data[:dob] || account[:dob]
    gender = kyc_data[:gender] || account[:gender]



    id = account.account_id
    body = {
      "data": {
        "type": 'Verification',
        "attributes": {
          "level": 'TIER_2',
          "level2": {
            "bvn": bvn,
            "dateOfBirth": dob,
            "gender": gender
          }
        }
      }
    }.to_json
    begin
      response = self.class.post("/api/v1/customers/#{id}/verification/individual", headers: @headers, body: body)

      raise response&.dig('errors', 0, 'detail') || 'bad request' unless response.success?

      message = response&.dig('data', 'attributes', 'message')
      raise 'account  not found' unless account
      unless account.update(status: 'verifying', dob: dob, bvn: bvn, gender: gender)
        raise account.errors.full_messages.to_sentence || 'bad request'
      end

      # return {response: response["data"], message: message, status: :ok}
      { response: account, message: message, status: :ok }
    rescue StandardError => e
      { message: e.message || 'bad request', status: :bad_request }
    end
  end

  def create_account_number(type = :individual, account)
    productType = 'SAVINGS'

    current_user = account[:account]

    id = account[:account][:account_id]
    account_type = { individual: 'IndividualCustomer', corporate: 'CorporateCustomer' }
    body = {
      "data": {
        "type": 'DepositAccount',
        "attributes": {
          "productName": productType
        },
        "relationships": {
          "customer": {
            "data": {
              "id": id,
              "type": 'IndividualCustomer'
            }
          }
        }
      }
    }.to_json

    begin
      raise "Invalid account type, Must be one of #{account_type.keys.join(', ')}" unless account_type.key?(type)

      response = self.class.post('/api/v1/accounts', headers: @headers, body: body)
      # account_number = response&.dig("data", "attributes", "bank", "accountNumber")
      # bank_name = response&.dig("data", "attributes", "bank", "accountName")


      bank_name = response.dig('data', 'attributes', 'bank', 'name')
      useable_id = response.dig('data', 'id')
      account_number = response.dig('data', 'attributes', 'accountNumber')
      account_name = response.dig('data', 'attributes', 'accountName')


      raise response.dig('errors', 0, 'detail') || 'bad request' unless response.success?

      unless current_user.update(account_number: account_number, account_type: type, status: 'completed',
                                 active: true, bank_name: bank_name, account_name: account_name, useable_id: useable_id)

        current_user.errors.full_messages.to_sentence || 'bad request'
      end

      #  return   {response: response["data"], status: :ok}
      { response: current_user, status: :ok }
    rescue StandardError => e
      { response: e.message.to_s, message: e.message || 'bad request', status: :bad_request }
    end
  end

  def inboundDepositedFund(inboundTransferId)
    response = self.class.get("/inbound-transfers/#{inboundTransferId}", headers: @headers)
    return response if response.success?

    raise response['message'] || 'bad request'
  rescue StandardError => e
    e.message.to_s || 'bad request'
  end

  def get_bank
    response = self.class.get('/banks', headers: @headers)
    return response if response.success?

    raise response['message'] || 'bad request'
  rescue StandardError => e
    e.message.to_s || 'bad request'
  end

  def verify_account
    response = self.class.get('/payments/verify-account/000014/0000000010 ', headers: @headers)
    return response if response.success?

    raise response['message'] || 'bad request'
  rescue StandardError => e
    e.message.to_s || 'bad request'
  end

  def create_counter_party(transfer_params)
    {
      "data": {
        "type": 'CounterParty',
        "attributes": {
          "bankCode": transfer_params['bank_code'],
          "accountName": transfer_params['account_name'],
          "accountNumber": transfer_params['account_number'],
          "verifyName": true
        }
      }
    }.to_json
    begin
      response = self.class.get('/payments/counterparties ', headers: @headers)
      return response if response.success?

      raise response['message'] || 'bad request'
    rescue StandardError => e
      e.message.to_s || 'bad request'
    end
  end

  def get_inbound_transfer(transfer_id)
    response = self.class.get("api/v1/inbound-transfers/#{transfer_id}", headers: @headers)

    raise response['message'] || 'bad request' unless response.success?

    receipient_id = response&.dig('relationships', 'account', 'data', 'id')
    amount = response&.dig('attributes', 'amount')
    sender = response&.dig('attributes', 'sourceAccountName')
    address = response&.dig('attributes', 'sourceAccountNumber')
    bank = response&.dig('attributes', 'sourceBank', 'name')

    account = Account.find_by(useable_id: receipient_id)

    user = account.user


    transaction_params = {
      wallet_id: user.wallet.id,
      amount: amount,
      address: address,
      sender: sender,
      bank_code: bank,
      bank: bank,
      transaction_type: 'deposit',
      status: 'approved',
      coin_type: 'bank'
    }


    transaction = Transaction.new(transaction_params)
    raise transaction.errors.full_messages.to_sentence unless transaction.persisted?
  rescue StandardError => e
    puts e.message
  end

  def initiate_transfer(receipient_params, source_id)
    {
      "data": {
        "type": 'NIPTransfer',
        "attributes": {
          "amount": receipient_params[:amount],
          "currency": 'NGN',
          "reason": ['description'],
          "reference": 'tthwubtvwt'
        },
        "relationships": {
          "account": {
            "data": {
              "id": source_id,
              "type": 'DepositAccount'
            }
          },
          "counterParty": {
            "data": {
              "id": receipient_params['id'],
              "type": 'CounterParty'
            }
          }
        }
      }
    }.to_json
    begin
      response = self.class.get('/payments/counterparties ', headers: @headers)
      return response if response.success?

      raise response['message'] || 'bad request'
    rescue StandardError => e
      e.message.to_s || 'bad request'
    end
  end

  def verify_transfer
    response = self.class.get("/verify/#{transferId}", headers: @headers)
    return response if response.success?

    raise response['message'] || 'bad request'
  rescue StandardError => e
    e.message.to_s || 'bad request'
  end


  private

  def store_account_details(account_id, user_data)
    new_account = Account.create(user_id: user_data[:user_id], postal_code: user_data[:postal_code],
                                 bvn: user_data[:bvn], city: user_data[:city], state: user_data[:state], dob: user_data[:dob], address: user_data[:address], account_id: account_id, vendor: user_data[:vendor])

    raise new_account.errors.full_messages.to_sentence unless new_account.persisted?

    new_account
  end

  def create_record(model, params); end
end
