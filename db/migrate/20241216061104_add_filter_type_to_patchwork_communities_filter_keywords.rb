class AddFilterTypeToPatchworkCommunitiesFilterKeywords < ActiveRecord::Migration[7.1]
  def change
    add_column :patchwork_communities_filter_keywords, :filter_type, :string, default: 'filter_out', null: false
  end
end
