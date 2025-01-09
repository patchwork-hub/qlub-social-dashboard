# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

class FetchDidValueService < BaseService
  def call(admin_account, target_account_id)
    @admin_account = admin_account
    fetch_did_value
  end

  private

  def fetch_did_value
    return unless @admin_account
    
    url = "https://fed.brid.gy/ap/@#{@admin_account&.username}@channel.org"
    response = HTTParty.get(url)
    if response.code == 200
      document = Nokogiri::HTML(response.body)
      did_value = document.at_css("button[onclick*='writeText']")&.attr('onclick')
      if did_value.nil?
        Rails.logger.error('DID value not found in response.')
      else
        did_value = did_value.match(/'([^']+)'/)[1]
        Rails.logger.info("DID Value:: #{did_value}")
        did_value
      end
    else
      Rails.logger.error("Error fetching DID: #{response.code} - #{response.message}")
    end
  end
end
