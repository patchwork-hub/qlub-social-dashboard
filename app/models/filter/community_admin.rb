class Filter::CommunityAdmin < Filter::Common
  def initialize(params)
    super(params)
  end

  def paginated_scope
    CommunityAdmin.offset((@current_page - 1) * @per_page).limit(@per_page)
  end

  def build_search
    CommunityAdmin.ransack(@q)
  end
end
