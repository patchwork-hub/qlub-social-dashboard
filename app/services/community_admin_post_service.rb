class CommunityAdminPostService < BaseService
  def initialize(community_admin)
    @community_admin = community_admin
  end

  def call
    create_admin!
  end

  private

  def create_admin!
    community = @community_admin.community
    return unless community

    avatar_file = community.avatar_image || ''
    header_file = community.banner_image || ''
    domain = ENV['LOCAL_DOMAIN'] || Rails.configuration.x.local_domain
    domain = domain.gsub(/^[^.]+\./, '')

    # Create or find account
    admin = Account.where(username: @community_admin.username).first_or_initialize(
      username: @community_admin.username,
      display_name: @community_admin.display_name,
      avatar: avatar_file,
      header: header_file,
      note: community.description
    )
    admin.save(validate: false)

    # Create or find user
    user = User.where(email: @community_admin.email).first_or_initialize(
      email: @community_admin.email,
      password: @community_admin.password,
      password_confirmation: @community_admin.password,
      confirmed_at: Time.now.utc,
      role: UserRole.find_by(name: @community_admin.role),
      account: admin,
      agreement: true,
      approved: true
    )
    user.save!

    # Link account with a cleanup policy
    policy = AccountStatusesCleanupPolicy.find_or_initialize_by(account_id: admin.id)
    policy.assign_attributes(enabled: true, min_status_age: 1.week.seconds)

    unless policy.save
      Rails.logger.error "Failed to create or update policy: #{policy.errors.full_messages.join(', ')}"
    end
  end
end
