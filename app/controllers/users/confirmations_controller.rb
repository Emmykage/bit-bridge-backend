# app/controllers/users/confirmations_controller.rb
class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    if resource.errors.empty?
      puts "✅ successful confirmation — redirect to your React app"
      render json: {message: "User confirmed"}, status: :ok
    else
      # ❌ failed confirmation — redirect with error message
      render json: {message: "Failed to Confirm"}, status: :unprocessable_entity
    end
  end
end
