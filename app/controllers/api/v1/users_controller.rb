class Api::V1::UsersController < ApplicationController
  before_action :set_user_params, only: %i[update_password]
  skip_before_action :authenticate_user!
  def user_profile
    render json: {data: UserSerializer.new(current_user)}, status: :ok
  end

  def update_password

    user_params

    if @user.update(user_params) &&  user_params[:password].present?
         render json: {message: "pasword has been updated"}
      else
      render json: {message: "failed to update password:  #{@user.errors.full_messages.to_sentence}"}, status: :unprocessable_entity

    end

  end

  def password_change





  end

  def set_user_params
    email = params[:user][:email]
    @user = User.find_by(email: email )
  end

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
