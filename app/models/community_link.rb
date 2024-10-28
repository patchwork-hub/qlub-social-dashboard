class CommunityLink < ApplicationRecord
  self.table_name = 'patchwork_community_links'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'

  enum icon: {
    pen: 'Pen',
    podcast: 'Podcast',
    message: 'Message',
    none_icon: 'None'
  }

end
