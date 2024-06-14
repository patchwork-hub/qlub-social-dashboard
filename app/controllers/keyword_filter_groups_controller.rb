class KeywordFilterGroupsController < ApplicationController
  before_action :set_keyword_filter_group, only: [:show, :edit, :update, :destroy, :update_is_active]

  def index
    @keyword_filter_groups = KeywordFilterGroup.all
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: prepare_filter_group_data }
    end
  end

  def new
    @keyword_filter_group = KeywordFilterGroup.new
    @keyword_filter_group.keyword_filters.build
  end

  def create
    @keyword_filter_group = KeywordFilterGroup.find_or_initialize_by(name: params[:keyword_filter_group][:name], server_setting_id: params[:keyword_filter_group][:server_setting_id])
    @keyword_filter_group.assign_attributes(keyword_filter_group_params)

    if @keyword_filter_group.save
      render json: { success: true }
    else
      render json: { success: false, error: @keyword_filter_group.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @keyword_filter_group.update(keyword_filter_group_params)
      redirect_to @keyword_filter_group, notice: 'Keyword filter group and keyword filter were successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @keyword_filter_group.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: keyword_filter_groups_url, notice: 'Keyword Filter Group deleted successfully' }
      format.json { render json: { success: true, message: 'Keyword Filter Group deleted successfully' } }
    end
  end

  def update_is_active
    if @keyword_filter_group.update(is_active: params[:keyword_filter_group][:is_active])
      render json: { success: true }
    else
      render json: { success: false, error: @keyword_filter_group.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  def set_keyword_filter_group
    @keyword_filter_group = KeywordFilterGroup.find(params[:id])
  end

  def keyword_filter_group_params
    params.require(:keyword_filter_group).permit(:name, :server_setting_id, keyword_filters_attributes: [:id, :keyword, :filter_type, :_destroy])
  end

  def prepare_filter_group_data
    data = {
      name: @keyword_filter_group.name,
      server_setting: ServerSetting.find_by_id(@keyword_filter_group.server_setting_id)&.name,
      is_active: @keyword_filter_group.is_active ? '<i class="fa-solid fa-check" style="color: green;"></i>' : '<i class="fa-solid fa-xmark" style="color: red;"></i>',
      keyword_filters: @keyword_filter_group.keyword_filters.map do |kf|
        {
          id: kf.id,
          keyword: kf.keyword,
          is_custom_group: @keyword_filter_group.is_custom,
          edit_url: keyword_filter_group_keyword_filter_path(@keyword_filter_group, kf) + '/edit',
          delete_url: keyword_filter_group_keyword_filter_path(@keyword_filter_group, kf)
        }
      end
    }

    { draw: params[:draw].to_i, recordsTotal: 1, recordsFiltered: 1, data: [data] }
  end
end
