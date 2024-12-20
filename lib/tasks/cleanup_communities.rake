# lib/tasks/cleanup.rake

namespace :cleanup do
  desc "Deletes communities, associated users, accounts and community admins"
  task :communities => :environment do
    puts "Starting community cleanup process..."
    Community.find_each do |community|
      puts "Processing community: #{community.id}..."

      begin
        ActiveRecord::Base.transaction do
          community.community_admins.each do |community_admin|
            if community_admin.account
              account = community_admin.account
              puts "Deleting account with ID: #{account.id} and associated user"

              user = account.user # this assumes you have a belongs_to :user in the Account model

              if user
                puts "Deleting user with ID: #{user.id} if they have one..."
                user.destroy
              else
                puts "Could not find a user associated with account ID: #{account.id}"
              end
              account.destroy

            else
              puts "Could not find a account associated with this community_admin with ID: #{community_admin.id}"

            end
          end
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
