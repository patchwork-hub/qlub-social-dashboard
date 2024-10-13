require 'aws-sdk-lambda'

class CreateCommunityInstanceDataWorker
  include Sidekiq::Worker
  WEB_PORT = 1000
  SIDEKIQ_PORT = 3000

  def perform(community)
    community_slug = community.slug
    domain = generate_domain(community_slug)

    lambda_client = initialize_lambda_client

    payload = build_payload(community, community_slug, domain)

    response = invoke_lambda(lambda_client, payload)

    handle_response(response)
  end

  private

  def generate_domain(community_slug)
    "#{community_slug}.channel.org"
  end

  def initialize_lambda_client
    Aws::Lambda::Client.new(region: ENV['S3_REGION'])
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
      WORKPLACE_DB_DATABASE: community_slug
    }.to_json
  end

  def calculate_web_port(community_id)
    WEB_PORT + community_id.to_i
  end

  def calculate_sidekiq_port(community_id)
    SIDEKIQ_PORT + community_id.to_i
  end

  def invoke_lambda(client, payload)
    client.invoke(
      function_name: 'GenerateCommunityInstanceJsonData',
      invocation_type: 'Event',
      payload: payload
    )
  end

  def handle_response(response)
    if response.successful?
      Rails.logger.info("Lambda function triggered successfully")
    else
      Rails.logger.error("Lambda invocation failed: #{response.inspect}")
    end
  end
end
