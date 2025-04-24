# lib/tasks/cleanup.rake

namespace :cleanup do
  desc "Deletes communities, associated users, accounts and community admins"
  task :communities, [:ids] => :environment do |t, args|
    ids_string = args[:ids] || ""
    community_ids = ids_string.split(",").map(&:strip).map(&:to_i)

    puts "Starting community cleanup process for #{community_ids.size} communities..."

    community_ids.each do |id|
      community = Community.find_by(id: id)

      if community.nil?
        puts "Community with ID: #{id} not found. Skipping..."
        next
      end

      puts "Processing community: #{community.id}..."

      begin
        ActiveRecord::Base.transaction do
          puts "Deleting community with ID: #{community.id}..."
          community.destroy
        end
        puts "Successfully deleted community #{community.id}"
      rescue StandardError => e
        puts "Error deleting community #{community.id}: #{e.message}"
      end
    end

    puts "Community cleanup process complete."
  end
end
