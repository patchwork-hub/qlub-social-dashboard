class CommunityLink < ApplicationRecord
  self.table_name = 'patchwork_community_links'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'
  validates :url, presence: true, uniqueness: { scope: :patchwork_community_id }

  enum icon: {
    pen: 'PenIcon',
    podcast: 'PodcastIcon',
    chat: 'ChatIcon',
    website: 'WebsiteIcon',
    rss_feed: 'RssFeedIcon',
    bluesky: 'Butterfly',
    thread: 'ThreadIcon',
    mastodon: 'Mastodon',
    message: 'MessageIcon',
    none_icon: 'None'
  }

end
