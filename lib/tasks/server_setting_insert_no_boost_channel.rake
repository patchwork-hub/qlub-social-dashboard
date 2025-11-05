namespace :server_setting do
  desc "Seed parent and child server settings data"
  task insert_no_boost_channel: :environment do
    puts "Inserting server settings & keywords..."

    settings_data = {
      "No-Boost Channels" => [
        { name: "No-Boost", value: false }
      ]
    }

    settings_data.each_with_index do |(parent_name, children), parent_index|
      parent = ServerSetting.find_or_initialize_by(name: parent_name, parent_id: nil)
      if parent.persisted?
        puts "Skipping existing parent setting: #{parent_name}"
      else
        parent.save!
        puts "Created parent setting: #{parent_name}"
      end

      children.each_with_index do |child, child_index|
        child_record = ServerSetting.find_or_initialize_by(
          name: child[:name],
          parent_id: parent.id
        )

        if child_record.persisted?
          puts "Skipping existing child setting: #{child[:name]}"
          next
        end

        child_record.assign_attributes(
          value: child[:value],
          position: child_index + 1
        )
        child_record.save!
        puts "Created child setting: #{child[:name]}"
      end
    end

    puts "Done inserting server settings & keywords"
  end
end
