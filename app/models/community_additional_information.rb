class CommunityAdditionalInformation < ApplicationRecord
  self.table_name = 'patchwork_community_additional_informations'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'
  validates :heading, :text, presence: true
end
