class KeywordFilterGroupsController < ApplicationController
  before_action :set_keyword_filter_group, only: [:show, :edit, :update, :destroy]

  def index
    @keyword_filter_group = KeywordFilterGroup.all
  end

  def show
  end

  def new
    @keyword_filter_group = KeywordFilterGroup.new
    @keyword_filter_group.keyword_filters.build
  end

  def create
    @keyword_filter_group = KeywordFilterGroup.find_or_initialize_by(name: params[:keyword_filter_group][:name])
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
    if @keyword_filter_group.update(is_active: params[:keyword_filter_group][:is_active])
      render json: { success: true }
    else
      render json: { success: false, error: @keyword_filter_group.errors.full_messages.join(', ') }
    end
  end

  def destroy
    @keyword_filter_group.destroy
    render json: { success: true, message: 'Keyword Filter Group deleted successfully' }
  end

  private

  def set_keyword_filter_group
    @keyword_filter_group = KeywordFilterGroup.find(params[:id])
  end

  def keyword_filter_group_params
    params.require(:keyword_filter_group).permit(:name, :server_setting_id, keyword_filters_attributes: [:id, :keyword, :filter_type, :_destroy])
  end
end
