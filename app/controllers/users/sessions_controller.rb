# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    skip_before_action :authenticate_user!, except: %i[create]

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


    def refresh
      raw = cookies.encrypted[:refresh_token] || request.headers['Bit-Refresh-Token']
      return render json: { message: 'no refresh token' }, status: :unauthorized unless raw

      user = current_user || User.find_by(refresh_token: raw)
      return render json: { error: 'invalid_refresh' }, status: :unauthorized unless user.validate_refresh_token(raw)

      user.revoke_refresh_token!
      new_refresh_token = user.generate_refresh_token
      access_token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
      render json:  { access_token: access_token, refresh_token: new_refresh_token }, status: :ok
    end


    private

    def respond_with(resource, _opts = {})
      refresh_token = resource.generate_refresh_token

      resource.update!(refresh_token: refresh_token, refresh_token_expires_at: 30.minutes.from_now)
      response.set_header('Bit-Refresh-Token', refresh_token)

      # UserMailer.login_alert(resource).deliver_now

      render json: {
        status: { code: 200, message: 'Logged in sucessfully.' },
        message: 'Logged in sucessfully.',
        data: UserSerializer.new(resource).as_json
      }, status: :ok
    end

    def respond_to_on_destroy
      if current_user
        render json: {
          status: 200,
          message: 'logged out successfully'
        }, status: :ok
      else
        render json: {
          status: 401,
          message: "Couldn't find an active session."
        }, status: :unauthorized
      end
    end
  end
end
