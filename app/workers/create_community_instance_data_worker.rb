require 'httparty'

class CreateCommunityInstanceDataWorker

  WEB_PORT = 1000
  SIDEKIQ_PORT = 3000
  LAMBDA_URL = ENV['CREATE_CHANNEL_LAMBDA_URL']
  LAMBDA_API_KEY = ENV['CREATE_CHANNEL_LAMBDA_API_KEY']

  def perform(community_id)
    community = Community.find(community_id)
    community_slug = community.slug
    domain = generate_domain(community_slug)

    payload = build_payload(community, community_slug, domain)

    response = invoke_lambda(payload)

    handle_response(response)
  end

  private

  def generate_domain(community_slug)
    "#{community_slug}.channel.org"
  end

  def build_payload(community, community_slug, domain)
    {
      client: community_slug,
      web: calculate_web_port(community.id),
      sidekiq: calculate_sidekiq_port(community.id),
      upstream_web: "#{community_slug}_web",
      upstream_stream: "#{community_slug}_stream",
      REDIS_NAMESPACE: community_slug,
      WEB_DOMAIN: domain,
      STREAMING_API_BASE_URL: "wss://#{domain}",
      LOCAL_DOMAIN: domain,
      WORKPLACE_DB_DATABASE: community_slug,
      AWS_ACCESS_KEY_ID: ENV['AWS_ACCESS_KEY_ID'],
      AWS_SECRET_ACCESS_KEY: ENV['AWS_SECRET_ACCESS_KEY']
    }.to_json
  end

  def calculate_web_port(community_id)
    WEB_PORT + community_id.to_i
  end

  def calculate_sidekiq_port(community_id)
    SIDEKIQ_PORT + community_id.to_i
  end

  def invoke_lambda(payload)
    response = HTTParty.post(
      LAMBDA_URL,
      body: payload,
      headers: {
        'Content-Type' => 'application/json',
        'x-api-key' => LAMBDA_API_KEY
      }
    )

    response
  end

  def handle_response(response)
    Rails.logger.info("Lambda invocation response: #{response.body}")
    if response.success?
      Rails.logger.info("Lambda function triggered successfully: #{response.body}")
    else
      Rails.logger.error("Lambda invocation failed: #{response.code} #{response.message}, Body: #{response.body}")
    end
  end
end
