class Transaction < ApplicationRecord
  belongs_to :wallet
  has_one_attached :proof
  has_one :user, through: :wallet

  enum :status, {pending: 0, approved: 1, declined: 2}
  # enum :coin_type, {usdt: 0, ngn: 1}
  enum :transaction_type, {deposit: 0, withdrawal: 1}
  enum :coin_type, {usdt: 0, bitcoin: 1, dodgecoin: 2, bank: 3}

  validate :validate_transaction, if: :withdrawal


  def validate_transaction

    if  amount > wallet.balance
      errors.add(:amount, "insufficient balance")

    end
  end

  def email
    user.email
  end









  def proof_url
    Rails.application.routes.url_helpers.url_for(proof) if proof.attached?
  end

    private

  def withdrawal
    transaction_type == "withdrawal" &&( status ==  "approved" || status == "pending")
  end



end
