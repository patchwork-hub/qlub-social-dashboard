namespace :migrate_newsmast_accounts do
  desc 'Migrate Newsmast accounts (usage: rake migrate_newsmast_accounts:create'
  task create: :environment do

    puts 'Staring Newsmast accounts migrations......'

    MigrateNewsmastAccountsJob.perform_later
  end
end