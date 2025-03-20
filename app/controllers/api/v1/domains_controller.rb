module Api
  module V1
    class DomainsController < ApiController
      skip_before_action :verify_key!
      before_action :authenticate_user_from_header

      def verify
        domain = params[:domain]
        expected_ip = ENV['SERVER_IP']

        verified = DnsVerifier.valid_a_record?(domain, expected_ip)
        message = verified ?
          "DNS configured correctly!" :
          "A record not found. Please point your A record to #{expected_ip}"

        render json: { verified: verified, message: message }
      end
    end
  end
end
