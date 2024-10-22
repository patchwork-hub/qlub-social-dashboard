class AddAttachmentAvatarImageBannerImageToCommunities < ActiveRecord::Migration[7.1]
  def self.up
    safety_assured do
      change_table :patchwork_communities do |t|
        t.attachment :avatar_image
        t.attachment :banner_image
      end
    end
  end

  def self.down
    remove_attachment :patchwork_communities, :avatar_image
    remove_attachment :patchwork_communities, :banner_image
  end
end
