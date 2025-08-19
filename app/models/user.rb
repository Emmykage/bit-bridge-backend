class User < ApplicationRecord

  attr_accessor :old_password, :confirm_password
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
        :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

        has_one :wallet, class_name: "Wallet"
        has_many :transactions, through: :wallet
        has_many :order_details
        has_many :order_items, through: :order_details
        has_many :card_tokens, through: :order_items
        has_one :user_profile
        has_many :bill_orders
        has_one :account


        accepts_nested_attributes_for :user_profile

        after_create :initialize_wallet

      default_scope {order(created_at: :desc)}



 def full_name
  "#{user_profile.first_name} #{user_profile.last_name}"
 end



  def user_net_expense
    order_details.sum(:total_amount)
  end


  def total_sale
    order_details.where(order_type: "sell", status: "approved").sum(:total_amount)
  end


  def admin
    role == 'admin'
  end


  def initialize_wallet
    # build_wallet unless wallet
    # Wallet.create(wallet_type: "usdt") #unless wallet
    create_wallet

  end


  def generate_refresh_token
    token = SecureRandom.hex(32)
      update!(refresh_token: token, refresh_token_expires_at: 30.minutes.from_now)
  end


  def validate_refresh_token(raw)
    return false unless refresh_token && refresh_token_expires_at && refresh_token_expires_at > Time.current
    return false unless raw == refresh_token

    true

  end


  def revoke_refresh_token!
    update!(refresh_token: nil, refresh_token_expires_at: nil)

  end





end
