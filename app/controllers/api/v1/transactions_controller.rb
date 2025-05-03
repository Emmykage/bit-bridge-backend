class Api::V1::TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show update destroy ]

  # GET /transactions
  def index
    @transactions = Transaction.all.order(created_at: :desc)

    render json:{data: @transactions}
  end

  def user
    transaction_type = params[:transaction_type]
    @transactions = current_user.transactions.order(created_at: :desc)
    @transactions = @transactions.where(transaction_type: transaction_type) if transaction_type.present?

    render json:{data:  ActiveModelSerializers::SerializableResource.new(@transactions)}
  end

  # GET /transactions/1
  def show
    render json: {data: TransactionSerializer.new(@transaction)}, status: :ok
  end

  def initialize_transaction
    initialize_payment = PaymentService.new
   response =  initialize_payment.init_transaction(transaction_params)
   if response[:status] == :ok
    transaction = current_user.wallet.transactions.create(
      status: "initialized",
      transaction_type: transaction_params[:transaction_type],
      amount: transaction_params[:amount]
    )

    if transaction.persisted?
     transaction_record = TransactionRecord.new(exchange_id: transaction.id, reference: response[:response]["responseBody"]["paymentReference"])

      if transaction_record.save
      render json:  transaction, status: :ok
      else
        render json: {message: transaction_record.errors.full_messages.to_sentence }, status: :unprocessable_entity

      end

    else
      render json: {message: transaction.errors.full_messages.to_sentence }, status: :unprocessable_entity

    end
   else
    render json: {message: response[:message]}, status: :bad_request
   end
  end


  def create

    # existing_wallet =  current_user.wallets.find_by(type: transaction_params[:currency])

  if current_user.wallet.nil?
    current_user.initialize_wallet
  end
   @wallet =  current_user.wallet
    @transaction = @wallet.transactions.new(transaction_params)

    if @transaction.save
      render json: {data: TransactionSerializer.new(@transaction), message: "Transaction created successfully" }, status: :created

    else
      render json:{message: @transaction.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /transactions/1
  def update
    if @transaction.update(transaction_params)
      render json:{data: @transaction, message: "updated successfully"}
    else
      render json: {message: @transaction.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
  end

  # DELETE /transactions/1
  def destroy
    @transaction.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.require(:transaction).permit(:status, :amount, :address, :proof, :transaction_type, :currency, :coin_type, :bank, :wallet_id, :coupon_code, :customer_name, :email, :description, :payment_purpose, :redirect_url)
    end

    def initialize_wallet(wallet_type)
      # build_wallet unless wallet
      current_user.wallets.create(type: wallet_type) #unless wallet

    end
end
