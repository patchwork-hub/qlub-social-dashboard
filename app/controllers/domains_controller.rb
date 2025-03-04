class DomainsController < ApplicationController
  def verify
    domain = params[:domain]
    # expected_ip = ENV['SERVER_IP']
    expected_ip = '18.134.76.246'

    verified = DnsVerifier.valid_a_record?(domain, expected_ip)
    message = verified ?
      "DNS configured correctly!" :
      "A record not found. Please point your A record to #{expected_ip}"

    render json: { verified: verified, message: message }
  end
end
