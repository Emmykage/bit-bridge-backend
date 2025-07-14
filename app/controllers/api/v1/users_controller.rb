class Api::V1::UsersController < ApplicationController
  before_action :set_user_params, only: %i[update_password]
  before_action :set_user, only: %i[show update destroy]
  skip_before_action :authenticate_user!, only: %i[update_password password_reset activate_user resend_confirmation_token ]
  def user_profile
    if current_user.nil?
      render json: { error: 'User not found or not authenticated' }, status: :unauthorized
    else
      render json: { data: UserSerializer.new(current_user) }, status: :ok
    end  end

  def index
    @users = User.all
    render json: {data: @users}, status: :ok


  end

  def show
    render json: {data: UserSerializer.new(@user)}, status: :ok
  end

  def update
    if @user.update(user_params)
         render json: {data: UserSerializer.new(@user), message: "User updated"}, status: :ok
      else
      render json: {message: @user.errors.full_messages.to_sentence}, status: :unprocessable_entity

    end

  end
def resend_confirmation_token
  user = User.find_by(email: params[:email])
  return render json: { message: "User not found" }, status: :not_found unless user

  if user.confirmed?
    return render json: { message: "User already confirmed" }.as_json, status: :unprocessable_entity
  end

  user.send_confirmation_instructions
  render json: { message: "Confirmation token resent", data: user }, status: :ok
end

  def activate_user
    if current_user.admin?
      user = User.find_by(email: params[:email])
      if @user.update(user_params)
        render json: {data: UserSerializer.new(@user), message: "User updated"}, status: :ok
      else
        render json: {message: @user.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end
    else
        render json: {message: "You are not authorized to perform this operation"}, status: :unprocessable_entity

    end
  end


  def update_password
  if @user.update(user_params)
         render json: {data: UserSerializer.new(@user), message: "password updated"}, status: :ok
      else
      render json: {message: @user.errors.full_messages.to_sentence}, status: :unprocessable_entity

    end
  end

   def user_update
    if current_user.update(user_params)
         render json: {data: UserSerializer.new(current_user), message: "User updated"}, status: :ok
      else
      render json: {message: current_user.errors.full_messages.to_sentence}, status: :unprocessable_entity

    end
  end

  def destroy
    if @user.destroy
         render json: { message: "User deleted"}, status: :ok
      else
      render json: {message: @user.errors.full_messages.to_sentence}, status: :unprocessable_entity

    end

  end

  def user_password_update
    if current_user.valid_password?(user_params[:old_password])
      if user_params[:password] == user_params[:confirm_password]
        if current_user.update(user_params)
           render json: {message: "pasword has been updated"}
          else
          render json: {message: "failed to update password:  #{current_user.errors.full_messages.to_sentence}"}, status: :unprocessable_entity
        end
      else
        render json: {message: "passwords do not match"}, status: :unprocessable_entity
      end
    else
      render json: {message: "old password is incorrect"}, status: :unprocessable_entity
    end

  end

  def password_reset
    email = params[:email]
    @user = User.find_by(email: email )
    generate_reset_token(@user)

    render json: {message: "A password reset link has been sent to you"}



  end

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def set_user_params
    email = params[:user][:email]
    @user = User.find_by(email: email )
  end




  def user_params
    params.require(:user).permit(:email, :acive, :password, :old_password, :confirm_password, :password_token, user_profile_attributes: [:id, :first_name, :last_name, :phone_number])
  end

  def generate_reset_token(user)
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)

    @token = raw
    user.reset_password_token = hashed
    user.reset_password_sent_at = Time.now
    if user.save
      puts "Token saved successfully!"
      UserMailer.send_password_reset(user, @token).deliver_later

    else
      puts "Failed to save token: #{user.errors.full_messages.join(", ")}"
    end
  end
end
