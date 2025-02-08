class BillOrder < ApplicationRecord

    enum :status, {initialized: 0, completed: 1, declined: 2}
    enum :meter_type, {PREPAID: 0, POSTPAID: 1}
    enum :payment_type, {online: 0, B2B: 1}

    validates :amount, presence: true

    before_save :calculate_total

    private

    def calculate_total

        self.total_amount = amount + 200
    end

end
