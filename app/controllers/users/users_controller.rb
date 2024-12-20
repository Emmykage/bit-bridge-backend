class Users::UsersController < ApplicationController
  def index

    binding.b
    render json: {data: current_user}, status: :ok
  end

  def update
  end

  # def delete
  # end
end
