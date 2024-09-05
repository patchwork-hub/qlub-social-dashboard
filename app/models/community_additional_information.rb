class CommunityAdditionalInformation < ApplicationRecord
  belongs_to :community, class_name: "Patchwork::Community"
end