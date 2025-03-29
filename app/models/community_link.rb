# == Schema Information
#
# Table name: patchwork_community_links
#
#  id                     :bigint           not null, primary key
#  icon                   :string
#  is_social              :boolean          default(FALSE)
#  name                   :string
#  url                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  patchwork_community_id :bigint           not null
#
# Indexes
#
#  index_community_links_on_url_and_patchwork_id              (url,patchwork_community_id) UNIQUE
#  index_patchwork_community_links_on_patchwork_community_id  (patchwork_community_id)
#
# Foreign Keys
#
#  fk_rails_...  (patchwork_community_id => patchwork_communities.id) ON DELETE => cascade
#
class CommunityLink < ApplicationRecord
  self.table_name = 'patchwork_community_links'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'
  validates :url, presence: true, uniqueness: { scope: :patchwork_community_id }
  enum :icon, {
    blog: "BlogIcon",
    podcast: "PodcastIcon",
    chat: "ChatIcon",
    website: "WebsiteIcon",
    rssfeed: "RssFeedIcon",
    bluesky: "Bluesky",
    thread: "ThreadIcon",
    mastodon: "Mastodon",
    message: "MessageIcon",
    video: "Video",
    linktree: "LinkTree",
    facebook: "Facebook",
    instagram: "Instagram",
    whatsapp: "WhatsApp",
    tiktok: "TikTok",
    pinterest: "Pinterest",
    snapchat: "Snapchat",
    pixelfed: "Pixelfed",
    reddit: "Reddit",
    x: "X"
  }

  scope :social, -> { where(is_social: true) }
  scope :general, -> { where(is_social: false) }

  # Icon categories
  SOCIAL_ICONS = %i[bluesky facebook instagram linktree mastodon pinterest pixelfed reddit snapchat thread tiktok whatsapp x].freeze

  GENERAL_ICONS = icons.keys.map(&:to_sym) - SOCIAL_ICONS

  # Helper to get icon image path
  def icon_image
    "icons/#{icon.to_s.dasherize}.svg"
  end
end
