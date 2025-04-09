# require 'set'

class Api::V1::BillOrdersController < ApplicationController
  before_action :set_bill_order, only: %i[ show update destroy ]

  # GET /bill_orders
  def index
    @bill_orders = BillOrder.all

    render json: {data: ActiveModelSerializers::SerializableResource.new(@bill_orders)}, status: :ok
  end

  def recent
    @bill_orders = BillOrder.select(:amount).distinct.order(created_at: :desc).limit(3)
    render json: { data: ActiveModelSerializers::SerializableResource.new(@bill_orders) }, status: :ok
  end

  def user

    bill_orders = current_user.bill_orders
    render json: {data: ActiveModelSerializers::SerializableResource.new(bill_orders)}, status: :ok
  end

  def user_recent

    bill_orders = current_user.bill_orders.order(created_at: :desc)
    unique_orders = []

    seen_amounts = Set.new

    bill_orders.each do |order|
      unless seen_amounts.include?(order.amount)
        unique_orders << order
        seen_amounts.add(order.amount)

        end
      end

    # unique_amounts = bill_orders.map(&:amount).uniq.first(3)
    # binding.b
    render json: {data: unique_orders.first(3)}, status: :ok
  end

  # GET /bill_orders/1
  def show

    render json: {data: BillOrderSerializer.new(@bill_order)}, status: :ok

  end

  # POST /bill_orders
  def create
    @bill_order = BillOrder.new(bill_order_params)

    if @bill_order.save
      render json: @bill_order, status: :created, location: @bill_order
    else
      render json: @bill_order.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bill_orders/1
  def update
    if @bill_order.update(bill_order_params)
      render json: @bill_order
    else
      render json: @bill_order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /bill_orders/1
  def destroy
    @bill_order.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bill_order
      @bill_order = BillOrder.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bill_order_params
      params.require(:bill_order).permit(:status, :meter_number, :amount, :meter_type, :phone, :service_type, :payment_type, :email, :tariff_class, :name)
    end
end
