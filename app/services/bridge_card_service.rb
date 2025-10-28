# frozen_string_literal: true

class BridgeCardService
  include HTTParty

  base_uri 'https://issuecards.api.bridgecard.co/v1/'

  def initialize
    @secret_key = ENV['BITBRIDGE_SECRET']
    token = ''
    @headers = {
      'token' => "Bearer #{token}",
      'Content-Type' => 'application/json'
    }
  end

  def register_cardholder_synchronously(account_params)
    first_name = account_params[:first_name]
    last_name = account_params[:last_name]
    address = account_params[:address]
    phone = account_params[:phone]
    account_params[:first_name]
    city = account_params[:city]
    state = account_params[:state]
    account_params[:postal_code]
    account_params[:postal_code]
    postal_code = account_params[:postal_code]
    email = account_params[:email]
    bvn = account_params[:bvn]


    begin
      body = {
        'first_name' => first_name,
        'last_name' => last_name,
        "address": {
          'address' => address,
          'city' => city,
          'state' => state,
          "country": 'Nigeria',
          "postal_code": postal_code,
          "house_no": '13'
        },
        "phone": phone,
        "email_address": email,
        "identity": {
          "id_type": 'NIGERIAN_BVN_VERIFICATION',
          "bvn": bvn,
          "selfie_image": 'https://image.com'
        },
        "meta_data": { "any_key": 'any_value' }

      }.to_json
      url = '/issuing/sandbox/cardholder/register_cardholder_synchronously'

      response = fetch(post, url, body)
      { data: response['data', status: :ok] }
    rescue StandardError => e
      { message: e.message, status: :bad_request }
    end
  end

  def call(params)
    cardholder_id = params[:cardholder_id]
    card_type = params[:card_type] || 'virtual' # "virtual" or "physical"
    card_brand = params[:card_brand] || 'Mastercard'
    card_currency = params[:card_currency] || 'USD'
    card_limit = params[:card_limit] || '500000'
    transaction_reference = params[:transaction_reference] || SecureRandom.uuid
    funding_amount = params[:funding_amount] || '0'
    pin = params[:pin]
    meta_data = params[:meta_data] || {}

    body = {
      'cardholder_id' => cardholder_id,
      'card_type' => card_type,
      'card_brand' => card_brand,
      'card_currency' => card_currency,
      'card_limit' => card_limit,
      'transaction_reference' => transaction_reference,
      'funding_amount' => funding_amount,
      'pin' => pin,
      'meta_data' => meta_data
    }

    response = self.class.post('/issuing/sandbox/cards/create_card', headers: @headers, body: body.to_json)
    handle_response(response)
  rescue StandardError => e
    { success: false, message: e.message }
  end

  # Fetch card details by card_id
  def card_details(card_id)
    raise ArgumentError, 'card_id is required' if card_id.blank?

    url = "/issuing/sandbox/cards/get_card_details?card_id=#{card_id}"

    response = fetch('get', url, body)
    { data: response['data'], status: :ok }
  rescue StandardError => e
    { success: false, message: e.message, status: bad_request }
  end

  # card balance
  def card_balance(card_id)
    raise ArgumentError, 'card_id is required' if card_id.blank?

    url = "/issuing/sandbox/cards/get_card_balance?card_id=#{card_id}"

    response = fetch('get', url, nil)
    { data: response['data'], status: :ok }
  rescue StandardError => e
    { success: false, message: e.message, status: bad_request }
  end

  def create_virtua_card(pin)
    encryped_pin = AES256.encrypt(pin, @secret_key)
    AES256.decrypt(encryped_pin, @secret_key)
    bitbridge_key
    cardholder_id = 'd0658fedf8284207866d96183fa'
    card_type = 'virtual' || 'physical'
    card_limit = '500000' || '1000000'
    reference = '',
                amount = '300'
    user_id = 'd0658fedf828420786e4a7083fa'


    body = {
      cardholder_id: cardholder_id,
      card_type: card_type,
      card_brand: 'Mastercard',
      card_currency: 'USD',
      card_limit: card_limit,
      transaction_reference: reference,
      funding_amount: amount,
      pin: encryped_pin,
      meta_data: { user_id: user_id }

    }.to_json

    url = '/issuing/sandbox/cards/create_card'

    fetch('post', url, body)
  rescue StandardError => e
    { message: e.message, status: :bad_request }
  end



  private

  def fetch(_method, _params, body)
    response = ''
    case _method
    when 'get'

      response = self.class.get(_url, headers: @headers)
    when 'post'

      response = self.class.post(_url,
                                 body: body, headers: @headers)

    else
      raise 'No method pased'

    end

    return response if response.success?



    raise response['message'] || 'failed to created card'
  rescue StandardError => e
    raise e.message || 'something went wrong'
  end
end
