class WaitListsController < ApplicationController
  before_action :authorize_master_admin!
  before_action :set_wait_list, only: %i[show edit update destroy]

  def index
    @wait_lists = load_wait_list_records
  end

  def show
  end

  def new
    @wait_list = WaitList.new
  end

  def edit
  end

  def create
    @wait_list = WaitList.new(wait_list_params)
    @wait_list.generate_invitation_code

    if @wait_list.save
      redirect_to @wait_list, notice: 'Wait list was successfully created.'
    else
      render :new
    end
  end

  def update
    if @wait_list.update(wait_list_params)
      redirect_to @wait_list, notice: 'Wait list was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @wait_list.destroy
    redirect_to wait_lists_url, notice: 'Wait list was successfully destroyed.'
  end

  def load_wait_list_records
    wait_list_records_filter.get
  end

  def wait_list_records_filter
    params[:q] = nil
    @filter = Filter::WaitList.new(params)
  end

  def authorize_master_admin!
    authorize :master_admin, :index?
  end

  private

  def set_wait_list
    @wait_list = WaitList.find(params[:id])
  end

  def wait_list_params
    params.require(:wait_list).permit(:email, :description, :invitation_code, :used)
  end
end
