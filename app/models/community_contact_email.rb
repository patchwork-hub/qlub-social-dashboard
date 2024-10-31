class CommunityContactEmail < ApplicationRecord
  self.table_name = 'patchwork_community_contact_emails'
  belongs_to :community, class_name: 'Community', foreign_key: 'patchwork_community_id'

end
