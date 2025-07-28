class Api::V1::WebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  def monnify
    data = JSON.parse(request.raw_post)
    Rails.logger.info("✅  Monnify webhook raw post: #{request.raw_post}")
    Rails.logger.info("✅  Monnify webhook json post: #{data}")


    if data["eventType"] == "SUCCESSFUL_TRANSACTION"
      transaction_reference = data["eventData"]["product"]["reference"]
      transaction_record = TransactionRecord.find_by(reference: transaction_reference)

      reference_type = transaction_reference.split("-")[0]

      case reference_type

      when "bbg"
        handle_bills_confirmation(transaction_record)
      when "fbg"
        handle_payment_confirmation(transaction_record)
      else
        handleTransactiomnConfirmation(transaction_reference)
        # Rails.logger.warn("Unknown refernce type: #{reference_type}")
      end

      head :ok

    end
  end



  def handleTransactiomnConfirmation(transaction_record)
    user_id = transaction_record["eventData"]["product"]["reference"]
     user = User.find_by(id: user_id)

    transaction_params = {
      wallet_id: user.wallet.id,
      amount: transaction_record["paymentSourceInformation"]["amountPaid"],
      address: transaction_record["paymentSourceInformation"]["accountNumber"],
      sender: transaction_record["paymentSourceInformation"]["accountName"],
      bank_code: transaction_record["paymentSourceInformation"]["bankCode"],
      transaction_type: "deposit",
      status: "approved",
      coin_type: "bank",
    }

    transaction = Transaction.create(transaction_params )

    if transaction.save?
      render json: {message: "Transaction confirmed successfully"}, status: :ok
    else
      render json: {message: transaction.errors.full_messages.to_sentence}, status: :unprocessable_entity
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
