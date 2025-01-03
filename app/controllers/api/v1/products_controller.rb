class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: %i[ show update destroy ]
  skip_before_action :authenticate_user!, only: %i[index]

  # GET /products
  def index
    @products = Product.all

    render json: {data: ActiveModelSerializers::SerializableResource.new(@products)}
  end

  # GET /products/1
  def show
    render json: @product
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      render json: {data: ProductSerializer.new(@product), message: "Product created"}, status: :created
    else
      render json: {message: @product.errors.full_messages}, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    @product.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:image, :featured, :extra_info, :provider, :provision, :category, :header_info, :description, :info, :rate, :attention, :notice_info, :min_value, :max_value)
    end
end
