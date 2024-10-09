class Collection < ApplicationRecord
  self.table_name = 'patchwork_collections'

  has_many :patchwork_communities,
            class_name: 'Community',
            foreign_key: 'patchwork_collection_id',
            dependent: :destroy


  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :sorting_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, uniqueness: true
end
