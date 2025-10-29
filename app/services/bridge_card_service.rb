# frozen_string_literal: true

class BridgeCardService
  include HTTParty

  base_uri 'https://issuecards.api.bridgecard.co/v1/'

  def initialize
    @secret_key = ENV['BITBRIDGE_SECRET']
    token = ENV['BRIDGE_CARD_TOKEN']
    @headers = {
      'token' => "Bearer #{token}",
      'Content-Type' => 'application/json'
    }
  end

  def register_cardholder_synchronously(account_params)
    first_name = account_params[:first_name]
    last_name = account_params[:last_name]
    address = account_params[:address]
    phone = account_params[:phone_number]
    city = account_params[:city]
    state = account_params[:state]
    house_no = account_params[:house_no]
    postal_code = account_params[:postal_code]
    email = account_params[:email]
    bvn = account_params[:bvn]


    card_params = {
      first_name: first_name,
      last_name: last_name,
      address: address,
      phone: phone,
      city: city,
      state: state,
      postal_code: postal_code,
      bvn: bvn,
      house_no: house_no,

      user_id: account_params[:user_id]


    }

    begin
      body = {
        'first_name' => first_name,
        'last_name' => last_name,
        "address": {
          'address' => address,
          'city' => city,
          'state' => state,
          'country' => 'Nigeria',
          'postal_code' => postal_code,
          'house_no' => house_no
        },
        'phone' => phone,
        'email_address' => email,
        "identity": {
          "id_type": 'NIGERIAN_BVN_VERIFICATION',
          "bvn": bvn,
          "selfie_image": 'https://image.com'
        },
        "meta_data": { "account_source": 'any_value' }

      }.to_json
      url = '/issuing/sandbox/cardholder/register_cardholder_synchronously'
      response = fetch('post', url, body)
      card = Card.create!(card_params)

      { data: card, message: response['message'], status: :ok }
    rescue StandardError => e
      { message: e.message, status: :bad_request }
    end
  end

  def create_card(params, card)
    cardholder_id = params[:cardholder_id]
    card_type = params[:card_type] || 'virtual' # "virtual" or "physical"
    card_brand = params[:card_brand] || 'Mastercard'
    card_currency = params[:card_currency] || 'USD'
    card_limit = params[:card_limit] || '500000'
    transaction_reference = params[:transaction_reference] || SecureRandom.uuid
    params[:funding_amount] || '0'
    pin = AES256.encrypt(params[:pin], @secret_key)
    # meta_data = params[:meta_data] || {}


    card_params = {
      cardholder_id: cardholder_id,
      card_type: card_type,
      card_brand: card_brand,
      card_currency: card_currency,
      card_limit: card_limit,
      transaction_reference: transaction_reference,
      amount: amount,
      pin: pin
    }

    body = {
      'cardholder_id' => cardholder_id,
      'card_type' => card_type,
      'card_brand' => card_brand,
      'card_currency' => card_currency,
      'card_limit' => card_limit,
      'transaction_reference' => transaction_reference,
      'funding_amount' => amount,
      'pin' => pin,
      "meta_data": { "account_source": 'any_value' }
    }.to_json

    response = fetch('post', '/issuing/sandbox/cards/create_card', body)

    card.update!(card_params)

    { data: card, message: response['message'], status: :ok }
    # handle_response(response)
  rescue StandardError => e
    { success: false, message: e.message, status: :bad_request }
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

  def fund_wallet(card_params)
    amount = card_params['amount']
    currency = card_params['currency'] || 'USD'
    body = {
      amount: amount
    }.to_json

    url = "/issuing/sandbox/cards/fund_issuing_wallet?currency=#{currency}"


    response = fetch('patch', url, body)

    { data: response['data'], message: response['message'], status: :ok }
  rescue StandardError => e
    { message: e.message, status: :bad_request }
  end

  def fund_card(_card_params)
    cardholder_id = 'd0658fedf8284207866d96183fa'
    amount = ''
    reference = ''

    body = {
      card_id: cardholder_id,
      amount: amount,
      transaction_reference: reference,
      currency: 'USD'

    }.to_json

    url = '/issuing/sandbox/cards/fund_card_asynchronously'

    fetch('patch', url, body)
    { data: response['data'], status: :ok }
  rescue StandardError => e
    { message: e.message, status: :bad_request }
  end



  private

  def fetch(_method, _url, body)
    response = ''
    case _method
    when 'get'

      response = self.class.get(_url, headers: @headers)
    when 'post'

      response = self.class.post(_url,
                                 body: body, headers: @headers)
    when 'patch'

      response = self.class.patch(_url,
                                  body: body, headers: @headers)

    else
      raise 'No method pased'

    end

    return response if response.success?

    raise response.dig('detail', 0, 'msg') || response['message'] || 'failed to created card'
  rescue StandardError => e
    raise e.message || 'something went wrong'
  end
end
