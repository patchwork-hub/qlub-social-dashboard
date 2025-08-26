namespace :newsmast_relays do
  desc "Create relays for hashtags in newsmast channels"
  task create: :environment do
    puts "Starting relay creation for newsmast channels..."
    
    # Find owner user to get the token
    owner_role = UserRole.find_by(name: 'Owner')
    owner_user = User.find_by(role: owner_role)
    
    unless owner_user
      puts "Owner user not found. Aborting relay creation."
      return
    end
    
    token = fetch_oauth_token(owner_user.id)
    api_base_url = ENV.fetch('MASTODON_INSTANCE_URL')
    
    # Fetch all newsmast channels
    newsmast_channels = Community.where(channel_type: 'newsmast')
    
    if newsmast_channels.empty?
      puts "No newsmast channels found."
      return
    end
    
    total_channels = newsmast_channels.count
    processed_count = 0
    success_count = 0
    error_count = 0
    
    puts "Found #{total_channels} newsmast channels"
    
    newsmast_channels.find_each do |community|
      processed_count += 1
      puts "[#{processed_count}/#{total_channels}] Processing community: #{community.name} (#{community.slug})"
      
      # Fetch hashtags for this community
      hashtags = CommunityHashtag.where(patchwork_community_id: community.id)
      
      if hashtags.empty?
        puts "  → No hashtags found for community: #{community.name}"
        next
      end
      
      puts "  → Found #{hashtags.count} hashtags"
      
      hashtags.each do |hashtag|
        begin
          create_relay(hashtag.hashtag, token, api_base_url)
          puts "  ✓ Created relay for hashtag: ##{hashtag.hashtag}"
          success_count += 1
        rescue StandardError => e
          puts "  ✗ Failed to create relay for hashtag: ##{hashtag.hashtag} - #{e.message}"
          error_count += 1
        end
      end
    end
    
    # Summary
    puts "\n=== Relay creation summary ==="
    puts "Total channels processed: #{processed_count}"
    puts "Relays created successfully: #{success_count}"
    puts "Errors encountered: #{error_count}"
    puts "Relay creation completed."
  end
  
  private
  
  def fetch_oauth_token(user_id)
    token_service = GenerateAdminAccessTokenService.new(user_id)
    token_service.call
  end
  
  def create_relay(hashtag_name, token, api_base_url)
    inbox_url = "https://relay.fedi.buzz/tag/#{hashtag_name}"
    
    unless Relay.exists?(inbox_url: inbox_url)
      CreateRelayService.new(api_base_url, token, hashtag_name).call
    else
      puts "  → Relay already exists for hashtag: ##{hashtag_name}"
    end
  end
end