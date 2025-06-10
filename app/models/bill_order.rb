class BillOrder < ApplicationRecord
    attr_accessor :demand_category
    belongs_to :user, optional: true
    has_one :wallet, through: :user
    has_one :transaction_record

    enum :status, {initialized: 0, completed: 1, declined: 2, timedout: 3}
    enum :meter_type, {PREPAID: 0, POSTPAID: 1}
    enum :payment_type, {online: 0, B2B: 1}
    enum :payment_method, {wallet: 0, card: 1}

    validates :amount, presence: true
    validate :validate_order, if: -> {persisted? && wallet_payment?}


    before_save :calculate_total
    before_save :set_usd_conversion
    before_save :cal_unit, if: :is_electricty?

    after_update :send_confirmation_mail, if: :is_completed?



    default_scope {order(created_at: :desc)}

    def calc_service_charge
        self.service_charge = service_type == "VTU" || service_type == "DATA" ? 0 : 100
    end


    def send_confirmation_mail

        OrderMailer.purchase_confirmation(self).deliver_now
    end

    def is_completed?
        status == "completed"
    end


    def cal_unit

        # NMD = 14.5 for 1000

        rate = 0

        case demand_category
        when "NMD"
            rate = 14.7
        when "NMD_2"
            rate = 14.7
        when "NMD_3"
            rate = 14.7
        else
            rate = 0.0
        end
        self.units = amount * (rate / 1000)
    end

    def is_electricty?
        service_type == "ELECTRICITY"
    end





    private

    def net_total
        amount.to_i + calc_service_charge
    end


    def calculate_total

        self.total_amount = net_total
    end

    def net_usd_conversion
        currency = CurrencyService.new("ngn", "ngn")

        amount_in_usd = currency.get_calculated_rate(net_total, "ngn", "ngn")
        usd_amount = amount_in_usd[:rate]

    end

    def set_usd_conversion



        self.usd_amount = net_usd_conversion

    end

    def wallet_payment?
        payment_method === "wallet"
    end
    def validate_order

        # binding.b
        if wallet.balance < net_usd_conversion

            errors.add(:amount, "insufficient balance")

        end

    end

end
