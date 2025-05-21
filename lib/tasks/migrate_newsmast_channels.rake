# frozen_string_literal: true

DEFAULT_REGISTRATION_MODE = 'none'
DEFAULT_ACCOUNT_STATUS = 0
DEFAULT_MIN_STATUS_AGE = 1.week.seconds
BACKEND_NEWSMAST_URL= 'https://backend.newsmast.org'

def extract_admin_username(input_string)
  match = input_string.match(/^@(\w+)@newsmast\.community$/)
  match ? match[1] : nil
end

def create_community(channel, community_type)
  attrs = channel[:attributes]
  slug = attrs[:slug].gsub('_', '-')

  Community.find_or_initialize_by(slug: slug).tap do |community|
    next if community.persisted?

    community.assign_attributes(
      name: attrs[:name],
      channel_type: Community.channel_types[:newsmast],
      patchwork_collection_id: attrs[:patchwork_collection_id],
      visibility: attrs[:visibility],
      registration_mode: DEFAULT_REGISTRATION_MODE,
      position: attrs[:position],
      patchwork_community_type_id: community_type.id
    )
  end
end

def find_or_create_community_admin(community, admin_username)
  account = Account.find_by(username: admin_username, domain: nil) || begin
    acc = Account.where(username: admin_username).first_or_initialize
    acc.save(validate: false)

    domain = 'channel.org'
    user = User.where(email: "#{admin_username}@#{domain}").first_or_initialize(email: "#{admin_username}@#{domain}", password: 'password', password_confirmation: 'password', confirmed_at: Time.now.utc, role: UserRole.find_by(name: 'UserAdmin'), account: acc, agreement: true, approved: true)
    user.save!
    acc
  end

  admin = CommunityAdmin.find_or_initialize_by(account_id: account.id, patchwork_community_id: community.id)
  return admin if admin.persisted?

  admin.assign_attributes(
    role: 'UserAdmin',
    display_name: community.slug,
    email: "#{admin_username}@channel.org",
    password: ENV.fetch('DEFAULT_ADMIN_PASSWORD', 'password'),
    is_boost_bot: true,
    account_status: DEFAULT_ACCOUNT_STATUS,
    username: admin_username
  )
  admin
end

def create_account_cleanup_policy(account_id)
  AccountStatusesCleanupPolicy.find_or_create_by(
    account_id: account_id,
    enabled: true, min_status_age: DEFAULT_MIN_STATUS_AGE
  )
end

def create_content_type(community)
  ContentType.find_or_create_by(
    patchwork_community_id: community.id,
    channel_type: ContentType.channel_types[:custom_channel],
    custom_condition: ContentType.custom_conditions['or_condition']
  )
end

def set_hashtags(community, user, channel = nil)
  return nil if community.nil? || user.nil?

  SetHashtagsJob.perform_later(community, user, channel, BACKEND_NEWSMAST_URL, @newsmast_account_token)
end

def fetch_oauth_token(user_id)
  token_service = GenerateAdminAccessTokenService.new(user_id)
  token_service.call
end

def fetch_followings(channel, account)
  FetchFollowingsJob.perform_later(channel, account, @owner_token, BACKEND_NEWSMAST_URL, @newsmast_account_token)
end

namespace :migrate_newsmast_channels do
  desc 'Migrate Newsmast channels (usage: rake migrate_newsmast_channels:create[newsmast_account_token])'
  task :create, [:token] => :environment do |_, args|

    puts 'Staring Newsmast migration......'

    @newsmast_account_token = args[:token] || 'eXRapzohPTadlcvzmfCLOMdkAAykVd634V1C85idKE8'

    owner_role = UserRole.find_by(name: 'Owner')
    owner_user = User.find_by(role: owner_role)

    unless owner_user
      puts 'Owner user not found. Aborting migration.'
      return
    end
    
    @owner_token = fetch_oauth_token(owner_user.id)

    community_type = CommunityType.find_by(slug: 'broadcast')
    unless community_type
      puts 'CommunityType with slug "broadcast" not found. Aborting migration.'
      return
    end

    created_count = skipped_count = error_count = 0

    [channel = NEWSMAST_CHANNELS.first(5)].compact.each_with_index do |channel, index|
      puts "Processing [#{index + 1}] #{channel[:attributes][:name]} : #{channel[:attributes][:slug]}"

      ActiveRecord::Base.transaction do
        begin
          # Create or find @community
          @community = create_community(channel, community_type)

          if @community.persisted?
            puts "  → Community already exists: #{@community.name}, skipping."
            skipped_count += 1
          end

          unless @community.valid?
            puts "  ✗ Failed to validate @community: #{@community.errors.full_messages.join(', ')}"
            error_count += 1
          end

          if @community.save
            puts "  ✓ Successfully created @community: #{@community.name}"
          else
            puts " ✗ Failed to save community: #{@community.errors.full_messages.join(', ')}"
            error_count += 1
            next
          end

          # Create @community admin
          admin_username = extract_admin_username(channel[:attributes][:community_admin][:username])
          if admin_username.nil?
            puts "  → Admin username not found for @community: #{@community.name}, skipping admin creation."
            skipped_count += 1
            next
          end

          @community_admin = find_or_create_community_admin(@community, admin_username)

          unless @community_admin.valid?
            puts "  ✗ Failed to validate @community admin: #{@community_admin.errors.full_messages.join(', ')}"
            error_count += 1
          end

          if @community_admin&.save
            puts "  ✓ Successfully created @community:#{@community.name} | admin: #{@community_admin.email}"
          else
            puts "  ✗ Failed to create @community admin for #{@community.name}: #{@community_admin&.errors&.full_messages&.join(', ')}"
            skipped_count += 1
            next
          end

          # Create account cleanup policy
          policy = create_account_cleanup_policy(@community_admin.account_id)
          if policy.save
            puts "  ✓ Successfully created AccountStatusesCleanupPolicy for admin: #{policy.account_id}"
          else
             skipped_count += 1
            puts "  ✗ Failed to create AccountStatusesCleanupPolicy: #{policy.errors.full_messages.join(', ')}"
          end

          # Create content type
          content_type = create_content_type(@community)
          if content_type.save
            puts "  ✓ Successfully created content type for @community: #{@community.name}"
          else
            puts "  ✗ Failed to create content type: #{content_type.errors.full_messages.join(', ')}"
          end
        rescue StandardError => e
          puts "  ✗ Error processing @community #{channel[:attributes][:name]}: #{e.message}"
          error_count += 1
          raise ActiveRecord::Rollback
        end
      end

      if @community_admin&.account
        # Fetch Newsmast's admin follwings and follow them
        fetch_followings(channel, @community_admin.account)
        puts "  ✓ Successfully followed contributor for @community: #{@community.name}"

        # Fetch hashtags from newsmast.social
        set_hashtags(@community, @community_admin&.account&.user, channel)
        puts "  ✓ Successfully set default hashtags for @community: #{@community.name}"
      else
        skipped_count += 1
        puts "  ✗ Skipped following contributors | hashtags admin account missing for #{@community.name}"
      end
       created_count += 1
    end

    # Summary
    puts '=== Newsmast @community creation summary ==='
    puts "Total processed: #{NEWSMAST_CHANNELS.size}"
    puts "Successfully created: #{created_count}"
    puts "Skipped: #{skipped_count}"
    puts "Errors: #{error_count}"
    puts '=== Process completed ==='
  end
end