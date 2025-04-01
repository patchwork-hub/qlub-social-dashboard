namespace :community_hashtags do
  desc "Reset hashtags for channel_feed communities"
  task reset: :environment do
    Community.where(channel_type: 'channel_feed').find_each do |community|
      account_id = community.community_admins&.first&.account_id
      if account_id.present?
        user_id = User.find_by(account_id: account_id)
        token = GenerateAdminAccessTokenService.new(user_id).call
        begin
          Community.transaction do
            community.patchwork_community_hashtags.each do |hashtag|
              ManageHashtagService.new(
                hashtag.hashtag,
                :unfollow,
                ENV['MASTODON_INSTANCE_URL'],
                token,
                community.id
              ).call
              hashtag.destroy!
            end

            default_hashtag = "#{community.slug.split('-').map(&:capitalize).join}Channel"

            unless CommunityHashtag.exists?(hashtag: default_hashtag, patchwork_community_id: community.id)
              CommunityHashtagPostService.new.call(hashtag: default_hashtag, community_id: community_id)
            end

            ManageHashtagService.new(
              default_hashtag,
              :follow,
              ENV['MASTODON_INSTANCE_URL'],
              token,
              community.id
            ).call
          end
          puts "Processed community #{community.slug} successfully"
        rescue StandardError => e
          puts "Failed to process community #{community.slug}: #{e.message}"
        end
      end
    end
  end
end
