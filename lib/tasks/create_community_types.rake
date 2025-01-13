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

    types.each_with_index do |(name, slug), index|
      CommunityType.find_or_create_by(name: name, slug: slug) do |community_type|
      community_type.sorting_index = index + 1
      end

      puts "Community type created or found => name: #{name}, slug: #{slug}"
    end

    puts "Community types created successfully."
  end
end