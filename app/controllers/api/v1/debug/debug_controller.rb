module Api::V1::Debug
  class DebugController < ApiController
    skip_before_action :verify_key!

    def queries
      render json: {
        n_plus_one: request.headers["X-N-Plus-One-Warnings"].presence || [],
        sql_profile: (JSON.parse(request.headers["X-SQL-Profile"]) rescue {})
      }
    end
  end
end