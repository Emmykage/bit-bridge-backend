class BillOrder < ApplicationRecord

    belongs_to :user
    has_one :wallet, through: :user

    enum :status, {initialized: 0, completed: 1, declined: 2}
    enum :meter_type, {PREPAID: 0, POSTPAID: 1}
    enum :payment_type, {online: 0, B2B: 1}

    validates :amount, presence: true
    validate :validate_order



    before_save :calculate_total
    before_save :set_usd_conversion





    private

    def net_total
        amount + 200
    end


    def calculate_total
        self.total_amount = net_total
    end

    def net_usd_conversion
        currency = CurrencyService.new("ngn", "usd")
        amount_in_usd = currency.get_calculated_rate(net_total)
        usd_amount = amount_in_usd[:rate]

    end

    def set_usd_conversion

        self.usd_amount = net_usd_conversion

    end
    def validate_order

        if wallet.balance < net_usd_conversion

            errors.add(:amount, "insufficient balance")

        end

    end

end
