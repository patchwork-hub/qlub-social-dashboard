class CommunityHashtag < ApplicationRecord
  self.table_name = 'mammoth_community_hashtags'

  belongs_to :community, inverse_of: :community_hashtags

  validates :hashtag, presence: true#, uniqueness: { scope: :community_id }
end