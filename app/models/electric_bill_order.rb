class ElectricBillOrder < ApplicationRecord


    enum :status, {initialized: 0, completed: 1, declined: 2}
end
