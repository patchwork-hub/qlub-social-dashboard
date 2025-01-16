module Scheduler
  class FetchDidValueScheduler
    include Sidekiq::Worker
    sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 15.minutes.to_i, queue: :scheduler

    def perform
      env = ENV.fetch('RAILS_ENV', nil)
      return if env == 'staging'

      communities = Community.where(did_value: nil).exlude_incomplete_channels
      return unless communities.any?

      communities.each do |community|
        return if community.nil?
        puts "[FetchDidValueScheduler] community: #{community.inspect}"

        community_admin = CommunityAdmin.find_by(patchwork_community_id: community&.id, is_boost_bot: true)
        return if community_admin.nil?
  
        user = User.find_by(email: community_admin&.email, account_id: community_admin&.account_id)
        return if user.nil?
  
        # Generate access token for community bot account
        @token = fetch_oauth_token(user)
        return if @token.nil?
  
        # Search for the bluesky bot account
        target_account = search_target_account
        return if target_account.nil?

        check_relationship = AccountRelationshipsService.new.call(user&.account, target_account.id)
        did_value = FetchDidValueService.new.call(target_account, community) if check_relationship
        
        if did_value
          community.update(did_value: did_value)
          Rails.logger.info("community: #{community.id} | #{community.name} | #{community.slug}, did_value: #{did_value}")
        
          # Create Record At DNS
          create_dns_record(did_value)

          # DM to @bsky.brid.gy@bsky.brid.gy
          puts "[FetchDidValueScheduler] status json: #{status_json(user&.account&.username)}"
          PostStatusService.new.call(token: @token, options: status_json(user&.account&.username))
        end
      end
    end

    private
    def search_target_account
      query = '@bsky.brid.gy@bsky.brid.gy'
      retries = 5
      result = nil
    
      while retries >= 0
        result = ContributorSearchService.new(query, url: ENV['MASTODON_INSTANCE_URL'], token: @token).call
        puts "[FetchDidValueScheduler] result: #{result}"
    
        if result.any?
          Rails.logger.info("[FetchDidValueScheduler - search_target_account] Found the Bluesky bot account. #{result}")
          return Account.find_by(id: result.last['id'])
        else
          Rails.logger.warn("[FetchDidValueScheduler - search_target_account] Attempt failed. Retrying...") if retries > 0
        end
    
        retries -= 1
      end
    
      Rails.logger.error("[FetchDidValueScheduler - search_target_account] Failed to find the Bluesky bot account after [#{retries}] multiple attempts.")
      nil
    end  
  
    def fetch_oauth_token(user)
      token_service = GenerateAdminAccessTokenService.new(user&.id)
      token_service.call
    end

    def status_json(username)
      env = ENV.fetch('RAILS_ENV', nil)
      domain = case env
      when 'staging'
        'staging.patchwork.online'
      when 'production'
        'channel.org'
      else
        'localhost:3000'
      end

      status = "@bsky.brid.gy@bsky.brid.gy #{username} [#{domain}]"
      {
        "in_reply_to_id": nil,
        "language": "en",
        "media_ids": [],
        "poll": nil,
        "sensitive": false,
        "spoiler_text": "",
        "status": status,
        "visibility": "direct"
      }
    end

    def create_dns_record(did_value)
      route53 = Aws::Route53::Client.new
      hosted_zones = route53.list_hosted_zones

      env = ENV.fetch('RAILS_ENV', nil)
      channel_zone = case env
      when 'staging'
        hosted_zones.hosted_zones.find { |zone| zone.name == 'staging.patchwork.online.' }
      when 'production'
        hosted_zones.hosted_zones.find { |zone| zone.name == 'channel.org.' }
      else
        hosted_zones.hosted_zones.find { |zone| zone.name == 'localhost.3000.' }
      end

      if channel_zone
        response = route53.change_resource_record_sets({
          hosted_zone_id:  channel_zone.id, # Hosted Zone for channel.org
          change_batch: {
            changes: [
              {
          action: 'UPSERT',
          resource_record_set: {
            name: 'channel.org', # Fully Qualified Domain Name
            type: 'TXT',
            ttl: 300,
            resource_records: [
              { value: "did=#{did_value}" },
            ],
          },
              },
            ],
          },
        })

        Rails.logger.info("Change ID: #{response.change_info.id}")
      else
         Rails.logger.error("Hosted zone for #{ENV.fetch('RAILS_ENV', nil)} not found.")
      end
    end
  end
end
