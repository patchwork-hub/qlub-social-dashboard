# frozen_string_literal: true

require 'httparty'
require 'nokogiri'

class FetchDidValueService < BaseService
  def call(admin_account, community)
    @admin_account = admin_account
    @community = community

    did_value = fetch_did_value(admin_account_url) || fetch_did_value(community_slug_url) || fetch_did_value(community_name_url)
    did_value
  end

  private

  def admin_account_url
    return unless @admin_account&.username

    "https://fed.brid.gy/ap/@#{@admin_account.username}@channel.org"
  end

  def community_slug_url
    return unless @community&.slug

    "https://fed.brid.gy/ap/@#{@community.slug}@channel.org"
  end

  def community_name_url
    return unless @community&.name

    "https://fed.brid.gy/ap/@#{@community.name}@channel.org"
  end

  def fetch_did_value(url)
    return if url.nil?

    response = HTTParty.get(url)
    if response.code == 200
      extract_did_value(response.body)
    else
      log_error("Error fetching DID: #{response.code} - #{response.message}")
      nil
    end
  end

  def extract_did_value(response_body)
    document = Nokogiri::HTML(response_body)
    onclick_value = document.at_css("button[onclick*='writeText']")&.attr('onclick')

    if onclick_value
      did_value = onclick_value.match(/'([^']+)'/)[1]
      log_info("DID Value:: #{did_value}")
      did_value
    else
      log_error('DID value not found in response.')
      nil
    end
  end

  def log_info(message)
    Rails.logger.info(message)
  end

  def log_error(message)
    Rails.logger.error(message)
  end
end
