# frozen_string_literal: true

module Scheduler

  class FollowBlueskyBotScheduler
    include Sidekiq::Worker
    sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 15.minutes.to_i, queue: :scheduler

    def perform
      return if ENV.fetch('RAILS_ENV', nil).eql?('staging')

      communities = Community.where(did_value: nil).exclude_incomplete_channels
      return unless communities.any?

      communities.each do |community|
        Rails.logger.info("[FollowBlueskyBotScheduler] community: id = #{community.id} | name =  #{community.name} | slug = #{community.slug}")

        community_admin = CommunityAdmin.find_by(patchwork_community_id: community&.id, is_boost_bot: true)
        next if community_admin.nil?

        account = community_admin&.account
        next if account.nil?
        Rails.logger.info("[FollowBlueskyBotScheduler] account: id = #{account.id} | username = #{account.username}")

        user = User.find_by(email: community_admin&.email, account_id: account&.id)
        next if user.nil?

        token = fetch_oauth_token(user)
        next if token.nil?

        target_account_id = Rails.cache.fetch('bluesky_bridge_bot_account_id', expires_in: 24.hours) do
          search_target_account_id(token)
        end
        target_account = Account.find_by(id: target_account_id)
        next if target_account.nil?

        account_relationship_array = handle_relationship(account, target_account.id)
        next unless account_relationship_array.present? && account_relationship_array&.last

        if account_relationship_array&.last['requested']
          UnfollowService.new.call(account, target_account)
        end

        Rails.logger.info("[FollowBlueskyBotScheduler] enable_bride_bluesky?: #{enable_bride_bluesky?(account)}")
        next unless enable_bride_bluesky?(account)

        if account_relationship_array&.last['following'] == true && account_relationship_array&.last['requested'] == false
          process_did_value(community, token, account)
        else
          FollowService.new.call(account, target_account)
          account_relationship_array = handle_relationship(account, target_account.id)
          process_did_value(target_account, community, token, account) if account_relationship_array.present? && account_relationship_array&.last && account_relationship_array&.last['following']
        end
      end
    end

    private

    def enable_bride_bluesky?(account)  
      account&.username.present? && account&.display_name.present?
    end

    def search_target_account_id(token)
      query = '@bsky.brid.gy@bsky.brid.gy'
      retries = 5
      result = nil
    
      while retries >= 0
        result = ContributorSearchService.new(query, url: ENV['MASTODON_INSTANCE_URL'], token: token).call
        if result.any?
          return result.last['id']
        end
        retries -= 1
      end
      nil
    end  

    def fetch_oauth_token(user)
      GenerateAdminAccessTokenService.new(user&.id).call
    end

    def process_did_value(community, token, account)
      did_value = FetchDidValueService.new.call(account, community)

      if did_value
        begin
          create_dns_record(did_value, community)
          sleep 1.minutes
          create_direct_message(token, community)
          community.update!(did_value: did_value)
        rescue StandardError => e
          Rails.logger.error("Error processing did_value for community #{community.id}: #{e.message}")
        end
      end
    end

    def create_dns_record(did_value, community)
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
        name = if community&.is_custom_domain?
                "_atproto.#{community.slug}"
              else
                "_atproto.#{community&.slug}.channel.org"
              end
        Rails.logger.info("[FollowBlueskyBotScheduler] Creating DNS record for #{name} with value #{did_value}")
        response = route53.change_resource_record_sets({
          hosted_zone_id:  channel_zone.id, # Hosted Zone for channel.org
          change_batch: {
            changes: [
              {
          action: 'UPSERT',
          resource_record_set: {
            name: name,
            type: 'TXT',
            ttl: 60,
            resource_records: [
              { value: "\"did=#{did_value}\"" },
            ],
          },
              },
            ],
          },
        })

        Rails.logger.info("[FollowBlueskyBotScheduler] Change ID: #{response.change_info.id}")
      else
        Rails.logger.error("Hosted zone for #{ENV.fetch('RAILS_ENV', nil)} not found.")
      end
    end

    def create_direct_message(token, community)

      name = if community&.is_custom_domain?
              community&.slug
            else
              "#{community&.slug}.channel.org"
            end

      status_params = {
        "in_reply_to_id": nil,
        "language": "en",
        "media_ids": [],
        "poll": nil,
        "sensitive": false,
        "spoiler_text": "",
        "status": "@bsky.brid.gy@bsky.brid.gy username #{name}",
        "visibility": "direct"
      }

      PostStatusService.new.call(token: token, options: status_params)
    end

    def handle_relationship(account, target_account_id)
      AccountRelationshipsService.new.call(account, target_account_id)
    end

  end
end
