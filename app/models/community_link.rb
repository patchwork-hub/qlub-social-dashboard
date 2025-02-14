class CommunityLink < ApplicationRecord
  self.table_name = 'patchwork_community_links'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'
  validates :url, presence: true, uniqueness: { scope: :patchwork_community_id }

  enum icon: {
    blog: 'BlogIcon',
    podcast: 'PodcastIcon',
    chat: 'ChatIcon',
    website: 'WebsiteIcon',
    rssfeed: 'RssFeedIcon',
    bluesky: 'Bluesky',
    thread: 'ThreadIcon',
    mastodon: 'Mastodon',
    message: 'MessageIcon',
    video: "Video",
    linktree: "LinkTree",
    facebook: "Facebook",
    instagram: "Instagram",
    whatsapp: "WhatsApp",
    tiktok: "TikTok",
    pintrest: "Pintrest",
    snapchat: "Snapchat",
    pixelfed: "Pixelfed",
    reddit: "Reddit",
    x: "X",
  }

  scope :social, -> { where(is_social: true) }
  scope :general, -> { where(is_social: false) }

  # Icon categories
  SOCIAL_ICONS = %i[bluesky facebook instagram linktree mastodon pintrest pixelfed reddit snapchat thread tiktok whatsapp x].freeze

  GENERAL_ICONS = icons.keys.map(&:to_sym) - SOCIAL_ICONS

  # Helper to get icon image path
  def icon_image
    "icons/#{icon.to_s.dasherize}.svg"
  end
end
