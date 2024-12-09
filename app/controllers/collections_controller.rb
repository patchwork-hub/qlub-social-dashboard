class CollectionsController < ApplicationController
  before_action :authorize_master_admin!
  before_action :set_collection, only: %i[show edit update]

  def index
    @search = Collection.ransack(params[:q])
    @records = @search.result.order(:sorting_index).page(params[:page])
  end

  def show
  end

  def new
    @collection = Collection.new
  end

  def create
      @collection = Collection.new(collection_params)
      if @collection.save
        redirect_to collections_path, notice: 'Collection was successfully created.'
      else
        #Rails.logger.error("Error creating collection: #{e.message}")
        flash.now[:error] = @collection.errors.full_messages
        render :new
      end
  end

  def edit
  end

  def update
    if @collection.update(collection_params)
      redirect_to collections_path, notice: 'Collection was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:name, :slug, :sorting_index, :banner_image, :avatar_image)
  end

  def authorize_master_admin!
    authorize :master_admin, :index?
  end
end
