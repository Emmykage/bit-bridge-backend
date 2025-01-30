class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

        has_one :wallet, class_name: "Wallet"
        has_many :transactions, through: :wallet
        has_many :order_details
        has_many :order_items, through: :order_details
        has_many :card_tokens, through: :order_items
  has_one :user_profile



  accepts_nested_attributes_for :user_profile



  after_create :initialize_wallet
  after_create :send_email_confirmation


  def user_net_expense
    order_details.sum(:total_amount)
  end




  def total_sale
    order_details.where(order_type: "sell", status: "approved").sum(:total_amount)
  end

  # def after_database_authentication
  #   create_wallet unless wallet
  # end


  def admin
    role == 'admin'
  end
  def initialize_wallet
    # build_wallet unless wallet
    create_wallet unless wallet
    # binding.b

  end

  def send_email_confirmation
    UserMailer.welcome_email(self).deliver_later
    # SendConfirmationEmailInstructionJob.perform_later

  end


end
