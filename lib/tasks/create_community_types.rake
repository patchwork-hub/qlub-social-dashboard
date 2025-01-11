namespace :community_types do
  desc "Create default community types"
  task create: :environment do
    types = [
      ["Broadcast", "broadcast"],
      ["Multi-platform", "multi-platform"],
      ["Multi-contributor", "multi-contributor"],
      ["Group", "group"],
      ["Curated", "curated"]
    ]

    types.each do |name, slug|
      CommunityType.create(name: name, slug: slug)
      puts "Community types created name: #{name}, slug: #{slug}"
    end

    puts "Community types created successfully."
  end
end