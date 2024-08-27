module Api
  module V1
    class ApiKeysController < ApiController

      def rotate
        @api_key.assign_attributes(api_key_params)
        if @api_key.save(validate: false)
          render json: {message: 'Success!'}, status: 200
        else
          render json: {error: @api_key.errors.full_messages}, status: 422
        end
      end

      private
      def api_key_params
        params.require(:api_key).permit(:status)
      end

    end
  end
end
