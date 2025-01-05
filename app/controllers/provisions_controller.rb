class ProvisionsController < ApplicationController
  before_action :set_provision, only: %i[ show update destroy ]

  # GET /provisions
  def index
    @provisions = Provision.all

    render json: @provisions
  end

  # GET /provisions/1
  def show
    render json: @provision
  end

  # POST /provisions
  def create
    @provision = Provision.new(provision_params)

    if @provision.save
      render json: @provision, status: :created, location: @provision
    else
      render json: @provision.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /provisions/1
  def update
    if @provision.update(provision_params)
      render json: @provision
    else
      render json: @provision.errors, status: :unprocessable_entity
    end
  end

  # DELETE /provisions/1
  def destroy
    @provision.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_provision
      @provision = Provision.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def provision_params
      params.require(:provision).permit(:name, :min_value, :max_value, :provision_value_type, :product_id)
    end
end
