class FollowNewsmastAccountJob < ApplicationJob
  queue_as :default

  def perform(csv_path = Rails.root.join('newsmast_adm_followers.csv'))
    @stats = {
      total_rows: 0,
      skipped_rows: 0,
      processed_handles: 0,
      successful_follows: 0,
      failed_follows: 0,
      community_not_found: 0,
      admin_not_found: 0,
      account_not_found: 0,
      invalid_handles: 0,
      target_account_not_found: 0
    }

    Rails.logger.info "Starting migration of accounts from #{csv_path}"

    unless File.exist?(csv_path)
      Rails.logger.error("CSV file not found at #{csv_path}")
      return { success: false, message: "CSV file not found" }
    end

    CSV.foreach(csv_path, headers: true).with_index(1) do |row, line_number|
      @stats[:total_rows] += 1
      process_row(row, line_number)
    rescue StandardError => e
      Rails.logger.error("Error processing line #{line_number}: #{e.message}\n#{e.backtrace.join("\n")}")
      next
    end

    log_final_stats
    { success: true, stats: @stats }
  end

  private

  def process_row(row, line_number)
    target_handles = row['followers']
    slug_val = row['slug']

    if slug_val.blank? || target_handles.blank?
      @stats[:skipped_rows] += 1
      Rails.logger.warn("Skipping row #{line_number}: Missing required fields (slug or followers)")
      return
    end

    # # Skip if slug doesn't contain a hyphen
    # unless slug_val&.include?('-')
    #   return
    # end

    community = find_community(slug_val, line_number)
    return unless community

    community_admin = find_community_admin(community, line_number)
    return unless community_admin

    account = Account.find_by(id: community_admin.account_id)
    unless account
      @stats[:account_not_found] += 1
      Rails.logger.error("Account not found for admin #{community_admin.id} in row #{line_number}")
      return
    end

    process_target_handles(target_handles, account, slug_val, line_number)
  end

  def find_community(slug_val, line_number)
    community = Community.find_by(slug: slug_val)
    
    unless community
      @stats[:community_not_found] += 1
      Rails.logger.error("Community not found for slug '#{slug_val}' in row #{line_number}")
      nil
    else
      community
    end
  end

  def find_community_admin(community, line_number)
    admin = community.community_admins.where(
      is_boost_bot: true,
      patchwork_community_id: community.id,
      account_status: 0
    ).last

    unless admin
      @stats[:admin_not_found] += 1
      Rails.logger.error("Admin not found for community #{community.id} in row #{line_number}")
      nil
    else
      admin
    end
  end

  def process_target_handles(target_handles, account, slug_val, line_number)
    target_handles.split(',').each do |raw_handle|
      @stats[:processed_handles] += 1
      handle = raw_handle.strip
      next if handle.blank?

      username, domain = extract_handle_components(handle, slug_val, line_number)
      next unless username && domain

      target_account = Account.find_by(username: username, domain: domain)
      unless target_account
        @stats[:target_account_not_found] += 1
        Rails.logger.warn("Target account not found for handle #{handle} in row #{line_number}")
        next
      end

      begin
        FollowService.new.call(account, target_account)
        @stats[:successful_follows] += 1
        Rails.logger.info("Successfully created follow from #{account.id} to #{target_account.id}")
      rescue StandardError => e
        @stats[:failed_follows] += 1
        Rails.logger.error("Failed to create follow from #{account.id} to #{target_account.id}: #{e.message}")
      end
    end
  end

  def extract_handle_components(handle, slug_val, line_number)
    unless handle.start_with?('@')
      @stats[:invalid_handles] += 1
      Rails.logger.warn("Invalid handle format '#{handle}' for slug '#{slug_val}' in row #{line_number}")
      return [nil, nil]
    end

    parts = handle[1..-1].split('@', 2)
    if parts.size != 2
      @stats[:invalid_handles] += 1
      Rails.logger.warn("Invalid handle format '#{handle}' for slug '#{slug_val}' in row #{line_number}")
      return [nil, nil]
    end

    parts
  end

  def log_final_stats
    Rails.logger.info "Migration completed with the following statistics:"
    Rails.logger.info "Total rows processed: #{@stats[:total_rows]}"
    Rails.logger.info "Rows skipped (missing data): #{@stats[:skipped_rows]}"
    Rails.logger.info "Handles processed: #{@stats[:processed_handles]}"
    Rails.logger.info "Successful follows: #{@stats[:successful_follows]}"
    Rails.logger.info "Failed follows: #{@stats[:failed_follows]}"
    Rails.logger.info "Communities not found: #{@stats[:community_not_found]}"
    Rails.logger.info "Admins not found: #{@stats[:admin_not_found]}"
    Rails.logger.info "Accounts not found: #{@stats[:account_not_found]}"
    Rails.logger.info "Invalid handles: #{@stats[:invalid_handles]}"
    Rails.logger.info "Target accounts not found: #{@stats[:target_account_not_found]}"
    
    Rails.logger.info "Success rate: #{calculate_success_rate}%"
  end

  def calculate_success_rate
    return 0 if @stats[:processed_handles] == 0
    (@stats[:successful_follows].to_f / @stats[:processed_handles] * 100).round(2)
  end
end