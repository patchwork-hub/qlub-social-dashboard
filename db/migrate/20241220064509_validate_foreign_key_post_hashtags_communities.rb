class ValidateForeignKeyPostHashtagsCommunities < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :post_hashtags_communities, :patchwork_communities
  end
end
