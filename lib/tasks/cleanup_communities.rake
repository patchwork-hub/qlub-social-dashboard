# lib/tasks/cleanup.rake

namespace :cleanup do
  desc "Deletes communities, associated users, accounts and community admins"
  task :communities => :environment do
    puts "Starting community cleanup process..."
    Community.find_each do |community|
      puts "Processing community: #{community.id}..."

      begin
        ActiveRecord::Base.transaction do
          puts "Deleting community with ID: #{community.id}..."
          community.destroy
        end

      rescue StandardError => e
        puts "Error deleting community #{community.id}: #{e.message}"
      end
    end

    puts "Community cleanup process complete."
  end
end
