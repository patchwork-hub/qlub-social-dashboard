namespace :server_setting do
  desc "Update ServerSetting names"
  task update_name: :environment do
    puts "Starting update ServerSetting names.."

    updates = {
      "Long posts and markdown" => "Long posts",
      "Server Settings"         => "Email Branding",
      "Search opt-out"          => "Automatic Search Opt-in",
      "Enable bluesky bridge"   => "Automatic Bluesky bridging for new users"
    }

    updates.each do |old_name, new_name|
      update_setting_name(old_name, new_name)
    end

    puts "End update ServerSetting names!"
  end

  def update_setting_name(old_name, new_name)
    setting = ServerSetting.find_by(name: old_name)

    if setting.present?
      setting.update!(name: new_name)
      puts "Updated ServerSetting: '#{old_name}' -> '#{new_name}'"
    else
      puts "No ServerSetting found with name '#{old_name}'"
    end
  end
end
