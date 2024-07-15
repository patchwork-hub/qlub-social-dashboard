class Form::AccountPaginator
  attr_reader :current_page, :total_pages, :per_page

  def initialize(page, per_page)
    @scope = public_scope
    @current_page = page
    @per_page = per_page
    @total_pages = (public_scope.count.to_f / per_page).ceil
  end

  def paginated_scope
    @scope.offset((@current_page - 1) * @per_page).limit(@per_page)
  end

  def prev_page
    @current_page > 1 ? @current_page - 1 : 1
  end

  def next_page
    @current_page < @total_pages ? @current_page + 1 : nil
  end

  def public_scope
    Account.all
  end

  def display_page
    if @current_page < 3
      @current_page
    else
      @current_page - 2
    end
  end

  def each_page
    (display_page..total_pages).map do |page|
      OpenStruct.new(number: page, current?: page == current_page)
    end
  end
end
