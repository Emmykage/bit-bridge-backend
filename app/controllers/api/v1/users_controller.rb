class Api::V1::UsersController < ApplicationController
  def user_profile
    render json: {data: UserSerializer.new(current_user)}, status: :ok
  end

  def update
  end

  # def delete
  # end
end
