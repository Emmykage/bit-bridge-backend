class Api::V1::StatisticsController < ApplicationController

    def index
        stats = Statistics.new
        render json: {
            data: {users: stats.total_users,total_withdrawals:  stats.total_withdrawals,  total_deposits: stats.total_deposits}
        },
        status: :ok

    end

end
