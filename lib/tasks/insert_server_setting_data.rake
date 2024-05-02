# lib/tasks/insert_server_setting_data.rake

namespace :db do
  desc "Seed parent and child settings data"
  task insert_server_setting_data: :environment do

    if ServerSetting.all.count > 0
      ServerSetting.destroy_all
    end
    
    if KeywordFilter.all.count > 0
      KeywordFilter.destroy_all
    end
    # Sample data for parent settings
    parent_settings_data = {
      "Spam Block" => [],
      "Content Moderation" => [],
      "Federation" => [],
      "Local Features" => [],
      "User Management" => [],
      "Plug-ins" => []
    }

    # Create parent settings and set positions
    parent_settings_data.each_with_index do |(parent_name, _), index|
      parent_setting = ServerSetting.create!(name: parent_name, value: nil)

      # Sample data for child settings with parent associations
      child_settings_data = {
        "Spam Block" => [
          { name: "Spam filters", value: true },
          { name: "Sign up challenge", value: false }
        ],
        "Content Moderation" => [
          { name: "Content filters", value: true },
          { name: "Live blocklist", value: true }
        ],
        "Federation" => [
          { name: "Bluesky", value: false },
          { name: "Threads", value: true }
        ],
        "Local Features" => [
          { name: "Custom theme", value: true },
          { name: "Search opt-out", value: true },
          { name: "Local only posts", value: true },
          { name: "Long posts and Markdown", value: true },
          { name: "Local quote posts", value: true },
        ],
        "User Management" => [
          { name: "Guest Accounts", value: true },
          { name: "e-Newsletters", value: true },
          { name: "Analytics", value: true }
        ],
        "Plug-ins" => []
      }

      child_settings_data[parent_name].each_with_index do |child, child_index|
        ServerSetting.create!(name: child[:name], value: child[:value], position: child_index + 1, parent_id: parent_setting.id)
      end
    end

    KeywordFilter.create(keyword: 'NSFW', server_setting_id: ServerSetting.where(name: 'Content Moderation', parent_id: nil).last&.id)
    KeywordFilter.create(keyword: 'Hate Speech', server_setting_id: ServerSetting.where(name: 'Content Moderation', parent_id: nil).last&.id)
    KeywordFilter.create(keyword: 'Crypto', server_setting_id: ServerSetting.where(name: 'Content Moderation', parent_id: nil).last&.id)
    KeywordFilter.create(keyword: 'porn', server_setting_id: ServerSetting.where(name: 'Content Moderation', parent_id: nil).last&.id, is_custom_filter: true)
    puts "Done insertion of server settings & keywords"
  end
end
