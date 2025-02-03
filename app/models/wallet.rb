class Wallet < ApplicationRecord
  belongs_to :user
  has_many :transactions, class_name: "Transaction"


  def total_deposit

  end

  def total_withdrawal
    # transactions.where(transaction_type: "withdrawal", status: "approved").sum(:amount)
    transactions.where(transaction_type: "withdrawal", status: [ "approved", "pending"]).sum(:amount)
  end

  def total_deposit
    transactions.where(transaction_type: "deposit", status: "approved").sum(:amount)
  end


  def balance

    (total_deposit + user.total_sale) - (total_withdrawal + user.user_net_expense)
  end



end