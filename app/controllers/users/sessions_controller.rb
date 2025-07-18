# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!, except: %i[create ]

  respond_to :json
  include RackSessionFix

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private
  def respond_with(resource, _opts = {})

  # UserMailer.login_alert(resource).deliver_now
  render json: {
    status: {code: 200, message: 'Logged in sucessfully.'},
     message: 'Logged in sucessfully.',
    data: UserSerializer.new(resource).as_json
  }, status: :ok
end
def respond_to_on_destroy
  if current_user
    render json: {
      status: 200,
      message: "logged out successfully"
    }, status: :ok
  else
    render json: {
      status: 401,
      message: "Couldn't find an active session."
    }, status: :unauthorized
  end
end
end
