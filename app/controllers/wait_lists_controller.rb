class WaitListsController < ApplicationController
	respond_to :html, :json
  before_action :get_selecte_and_unselected, only: [:invitation_codes, :export]
	before_action :set_wait_list, only: %i[ show invitation_code ]
  before_action :get_role, only: %i[ create ]
  load_and_authorize_resource

	def index
		respond_to do |format|
      format.html
      format.json {render json: prepare_wait_list_for_datatable}
    end
	end

	def show; end

  def invitation_codes
		respond_to do |format|
      format.html
      format.json {render json: prepare_invitation_codes_for_datatable}
    end
	end

  def invitation_code; end

  def invitation_code_list 
    ids = params[:ids].split(',')
    @wait_lists = WaitList.where(id: ids) if ids.any?
  end

	def create
    if @role
      @wait_list = generate_code
      redirect_to invitation_code_path(@wait_list), notice: 'A new invitation code was successfully created.'
    else
      flash[:error] = 'Invitation code creation failed. Role is required!'
      redirect_to invitation_codes_url
    end
	end

  def export
    if request.post?
      if params[:email].present?
        ExportExcelJob.perform_later email: params[:email], role: params[:role], limit: params[:limit], type: "#{params[:type]}_invitation_code", selected: @selected, unselected: @unselected, q: params[:q]

        redirect_to invitation_codes_url, notice: 'The export of invitation codes is in process. The system will send you an email that you provided with a download link when it is ready.'
      else
        flash[:error] = 'Please fill out these fields.'
        render :export
      end
    end
  end

	private

		def set_wait_list
			@wait_list = WaitList.find(params[:id])
		end

    def get_role
      roles = ['contributor', 'end-user', 'moderator'].freeze
      @role = params[:role] if roles.include? params[:role]
    end

    def generate_code
      combile = (1..9).to_a + ('a'..'z').to_a
      uniq_code = (0...4).collect { combile[Kernel.rand(combile.length)] }.join
      
      generate_code if WaitList.find_by(invitation_code: uniq_code).present?

      @wait_list = WaitList.create(invitation_code: uniq_code, role: @role)
    end
	
		def prepare_wait_list_for_datatable
			@all 				= WaitList.select('mammoth_wait_lists.id, mammoth_wait_lists.email, mammoth_wait_lists.role, mammoth_wait_lists.created_at, mammoth_contributor_roles.name as cr_name')
														.joins('left join mammoth_contributor_roles on mammoth_wait_lists.contributor_role_id = mammoth_contributor_roles.id')
														.where.not(email: nil)
			@wait_lists = @all
			if @q.present?
				@wait_lists = @wait_lists.where("mammoth_wait_lists.email like :q 
																				OR mammoth_wait_lists.role like :q 
																				OR mammoth_contributor_roles.name like :q", 
																				q: "%#{@q}%")
			end
			@wait_lists = @wait_lists.order("#{@sort}": :"#{@dir}").page(@page).per(@per)
			@data = @wait_lists.each_with_object([]) { |w, arr| 
	      arr << {
	        email: 	 w.email, 
	        role: 	 w.role || '-',
	        cr_name: w.cr_name || '-',
          created_at: w.created_at.strftime('%b %d, %Y - %I:%M %p'),
	        actions: "<a href=#{wait_list_url(w.id)} title='view'><i class='fa-solid fa-eye'></i></a>"
	      }
	    }

	    total_records  = @all.size
	    total_filtered = @q.present? ? @wait_lists.total_count : total_records

	    {draw: params[:draw], recordsTotal: total_records, recordsFiltered: total_filtered, data: @data}
	  end

	  def prepare_invitation_codes_for_datatable
      @all 				= WaitList.get_invitation_codes
	  	@wait_lists = @all
			
      if @q.present?
				@wait_lists = @wait_lists.where("mammoth_wait_lists.invitation_code like :q OR mammoth_wait_lists.role like :q OR accounts.username like :q", q: "%#{@q.downcase}%")
			end

			@wait_lists = @wait_lists.order("#{@sort}": :"#{@dir}").page(@page).per(@per) if @dir.present?

			@data = @wait_lists.each_with_object([]) { |w, arr|
        if @selected == 'all'
          checked = !@unselected.map(&:to_i).include?(w.id)
        else
          checked = @selected.map(&:to_i).include?(w.id)
        end
        
        arr << {
          id:                     "<input type='checkbox' class='mx-auto mt-1 form-check checkbox' value='#{w.id}' id='code-#{w.id}' #{checked ? 'checked' : ''}>",
	        invitation_code: 		     w.invitation_code,
          role:                    w.role || '-',
	        is_invitation_code_used: w.is_invitation_code_used ? 'Yes' : 'No',
          username:                w.account_id ? "<a href=#{account_url(w.account_id)}>#{w.username}</a>" : '-'
	      }
	    }

	    total_records  = @all.size
	    total_filtered = @q.present? ? @wait_lists.total_count : total_records

	    {draw: params[:draw], recordsTotal: total_records, recordsFiltered: total_filtered, data: @data}
	  end

    def get_selecte_and_unselected
      @selected    = params[:selected]
      unless @selected == 'all'
        unless @selected.is_a?(Array)
          @selected  = @selected.to_s.split(',')
        end
      end

      @unselected    = params[:unselected]
      unless @unselected.is_a? Array
        @unselected  = @unselected.to_s.split(',')
      end
    end

end

