class Api::V1::WebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  def monnify
    data = JSON.parse(request.raw_post)
    # Rails.logger.info("✅  Monnify webhook json post: #{data}")


    if data["eventType"] == "SUCCESSFUL_TRANSACTION"
      event_data = data["eventData"]
      transaction_reference = data["eventData"]["product"]["reference"]
      transaction_record = TransactionRecord.find_by(reference: transaction_reference)

      reference_type = transaction_reference.split("-")[0]

          Rails.logger.info("✅  Monnify webhook reference post: #{transaction_reference}")


      case reference_type

      when "bbg"
        handle_bills_confirmation(transaction_record)
      when "fbg"
        handle_payment_confirmation(transaction_record)
      else
        handleTransactionConfirmation(event_data)
        # Rails.logger.warn("Unknown refernce type: #{reference_type}")
      end

      head :ok

    end
  end



  def handleTransactionConfirmation(event_data)
    user_id = event_data["product"]["reference"]
     user = User.find_by(id: user_id)

     unless user
      Rails.logger.error("❌ User with ID #{user_id} not found")
      return
    end

    unless user.wallet
      Rails.logger.error("❌ Wallet not found for user #{user.id}")
      return
    end

    Rails.logger.info("✅  Monnify webhook raw post: #{transaction_record}")

  payment_info = event_data["paymentSourceInformation"].first


    transaction_params = {
      wallet_id: user.wallet.id,
      amount: payment_info["amountPaid"],
      address: payment_info["accountNumber"],
      sender: payment_info["accountName"],
      bank_code: payment_info["bankCode"],
      transaction_type: "deposit",
      status: "approved",
      coin_type: "bank",
    }

   transaction = Transaction.new(transaction_params)

  if transaction.save
    Rails.logger.info("✅ Transaction saved: #{transaction.inspect}")
  else
    Rails.logger.error("❌ Transaction failed: #{transaction.errors.full_messages.to_sentence}")
  end

  end




  def handle_bills_confirmation(transaction_record)
    payment_method = "card"
    bill_order =  transaction_record.bill_order
    payment_service = BuyPowerPaymentService.new
    service_response = payment_service.confirm_subscription(bill_order, payment_method)

  #  if service_response[:status] == "success"
  #   render json: {data: service_response[:response]}, status: :ok
  #   else
  #     render json: {message: service_response[:response]}, status: :ok

  #   end





  end


  def handle_payment_confirmation(transaction_record)
  transaction =   transaction_record.exchange
  transaction.update(status: "approved")


  end
end
