class Wallet < ApplicationRecord
  belongs_to :user
  has_many :transactions, class_name: "Transaction"
  has_many :bill_orders, through: :user
  has_many :order_details, through: :user

  def total_bills
    bill_orders.where(status: "completed").sum(:usd_amount)
  end

  def total_withdrawal
    # transactions.where(transaction_type: "withdrawal", status: "approved").sum(:amount)
    transactions.where(transaction_type: "withdrawal", status: [ "approved", "pending"]).sum(:amount)
  end

  def total_deposit
    transactions.where(transaction_type: "deposit", status: "approved").sum(:amount)
  end


  def balance
     (total_deposit + user.total_sale) - (total_withdrawal + user.user_net_expense + total_bills)
  end



end