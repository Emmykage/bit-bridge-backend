class OrderMailer < ApplicationMailer
  default from: 'orders@bitbridgeglobal.com'

  def purchase_confirmation(order)
    @order = order
    mail(
      to: @order.email,
      subject: "BitBridge Global - Purchase Confirmation (Order ##{@order.transaction_id})"
    )
  end
end