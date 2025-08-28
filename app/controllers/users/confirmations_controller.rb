# frozen_string_literal: true

# app/controllers/users/confirmations_controller.rb
module Users
  class ConfirmationsController < Devise::ConfirmationsController
    # GET /confirmation?confirmation_token=abcdef
    def show
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      if resource.errors.empty?
        user = resource

        new_refresh_token = user.generate_refresh_token
        access_token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
        puts '✅ successful confirmation — redirect to your React app'
        render json: { message: 'User confirmed', refresh_token: new_refresh_token, access_token: access_token },
               status: :ok
      else
        # ❌ failed confirmation — redirect with error message
        render json: { message: 'Failed to Confirm' }, status: :unprocessable_entity
      end
    end
  end
end
