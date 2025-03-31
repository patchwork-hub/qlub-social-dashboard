# == Schema Information
#
# Table name: patchwork_community_contact_emails
#
#  id                     :bigint           not null, primary key
#  contact_email          :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  patchwork_community_id :bigint           not null
#
# Indexes
#
#  idx_on_patchwork_community_id_a7f23c413c  (patchwork_community_id)
#
# Foreign Keys
#
#  fk_rails_...  (patchwork_community_id => patchwork_communities.id) ON DELETE => cascade
#
class CommunityContactEmail < ApplicationRecord
  self.table_name = 'patchwork_community_contact_emails'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'

end
