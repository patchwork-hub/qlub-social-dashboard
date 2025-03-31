# == Schema Information
#
# Table name: patchwork_community_additional_informations
#
#  id                     :bigint           not null, primary key
#  heading                :string
#  text                   :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  patchwork_community_id :bigint           not null
#
# Indexes
#
#  idx_on_patchwork_community_id_018a30d4a0  (patchwork_community_id)
#
# Foreign Keys
#
#  fk_rails_...  (patchwork_community_id => patchwork_communities.id) ON DELETE => cascade
#
class CommunityAdditionalInformation < ApplicationRecord
  self.table_name = 'patchwork_community_additional_informations'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'
  validates :heading, :text, presence: true
end
