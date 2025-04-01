namespace :community_hashtags do
  desc "Reset hashtags for channel_feed communities"
  task reset: :environment do
    owner_role = UserRole.find_by!(name: 'Owner')
    owner_user = User.find_by!(role: owner_role)
    owner_token = GenerateAdminAccessTokenService.new(owner_user.id).call

    Community.where(channel_type: 'channel_feed').find_each do |community|
      begin
        Community.transaction do
          community.patchwork_community_hashtags.each do |hashtag|
            ManageHashtagService.new(
              hashtag.hashtag,
              :unfollow,
              ENV['MASTODON_INSTANCE_URL'],
              owner_token,
              community.id
            ).call
            hashtag.destroy!
          end

          default_hashtag = "#{community.slug.split('-').map(&:capitalize).join}Channel"

          unless CommunityHashtag.exists?(hashtag: default_hashtag, patchwork_community_id: community.id)
            CommunityHashtag.create!(
              hashtag: default_hashtag,
              name: default_hashtag,
              patchwork_community_id: community.id
            )
          end

          ManageHashtagService.new(
            default_hashtag,
            :follow,
            ENV['MASTODON_INSTANCE_URL'],
            owner_token,
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
