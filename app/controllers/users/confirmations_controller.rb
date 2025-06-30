# app/controllers/users/confirmations_controller.rb
class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      # ✅ successful confirmation — redirect to your React app
      redirect_to "https://bitbridgeglobal.com/confirmation-success"
    else
      # ❌ failed confirmation — redirect with error message
      redirect_to "https://bitbridgeglobal.com/confirmation-error"
    end
  end
end
