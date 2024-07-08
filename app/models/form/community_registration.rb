def community_params
  params.require(:community).permit(
    :name,
    :slug,
    :description,
    :collection_id,
    :position,
    :is_recommended,
    :bio,
    :image,
    guides:[:position,:title,:description])
end

class CommunityRegistration < ApplicationRecord
  attr_accessor :current_step

  validaties :
end