class Api::V1::OrderDetailsController < ApplicationController
  before_action :set_order_detail, only: %i[ show update destroy ]

  # GET /order_details
  def index
    @order_details = current_user.order_details

    render json: {data: @order_details}, status: :ok
  end

  # GET /order_details/1
  def show
    render json: @order_detail
  end

  # POST /order_details
  def create
    @order_detail = OrderDetail.new(order_detail_params)

    if @order_detail.save
      render json: @order_detail, status: :created, location: @order_detail
    else
      render json: @order_detail.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /order_details/1
  def update
    if @order_detail.update(order_detail_params)
      render json: @order_detail
    else
      render json: @order_detail.errors, status: :unprocessable_entity
    end
  end

  # DELETE /order_details/1
  def destroy
    @order_detail.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_detail
      @order_detail = OrderDetail.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def order_detail_params
      params.require(:order_detail).permit(:total_amount, :status, :payment_method, :viewed, :net_total)
    end
end
