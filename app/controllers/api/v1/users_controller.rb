class Api::V1::UsersController < ApplicationController
  before_action :set_user_params, only: %i[update_password]
  skip_before_action :authenticate_user!, only: %i[update_password password_reset]
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

  def update_password

    if @user.update(password: user_params[:password]) &&  user_params[:password].present?
         render json: {message: "pasword has been updated"}
      else
      render json: {message: "failed to update password:  #{@user.errors.full_messages.to_sentence}"}, status: :unprocessable_entity

    end

  end

  def password_reset



    email = params[:email]
    @user = User.find_by(email: email )
    generate_reset_token(@user)

    render json: {message: "A password reset link has been sent to you"}



  end

  def set_user_params
    email = params[:user][:email]
    @user = User.find_by(email: email )
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_token, )
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
