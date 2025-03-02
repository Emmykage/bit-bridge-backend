class Transaction < ApplicationRecord
  belongs_to :wallet
  has_one_attached :proof
  has_one :user, through: :wallet

  enum :status, {pending: 0, approved: 1, declined: 2}
  # enum :coin_type, {usdt: 0, ngn: 1}
  enum :transaction_type, {deposit: 0, withdrawal: 1}
  enum :coin_type, {usdt: 0, bitcoin: 1, dodgecoin: 2, bank: 3}

  default_scope { order(created_at: :desc)}
  validate :validate_transaction, if: :withdrawal

  before_save :check_method_payment


  def validate_transaction

    if  amount > wallet.balance
      errors.add(:amount, "insufficient balance")

    end
  end
  def check_method_payment
    if  coin_type === "bank"
      self.status = "approved"
    end

  end

  def email
    user.email
  end

  # def insert_usd

  # end










  def proof_url
    Rails.application.routes.url_helpers.url_for(proof) if proof.attached?
  end

    private

  def withdrawal
    transaction_type == "withdrawal" &&( status ==  "approved" || status == "pending")
  end



end
