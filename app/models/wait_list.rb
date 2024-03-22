require 'spreadsheet'

class WaitList < ApplicationRecord
	self.table_name = 'mammoth_wait_lists'

	include CodeGenerator

	belongs_to :contributor_role, inverse_of: :wait_lists, optional: true

  validates :invitation_code, presence: true, uniqueness: true

	scope :matching, -> q { where("email like :q OR invitation_code like :q", q: "%#{q}%") }

  def self.to_xlsx(params={})
    @list = self.get_invitation_codes(params)

    Spreadsheet.client_encoding = 'UTF-8'

    head_format = Spreadsheet::Format.new size:    14,
                                          weight: :bold,
                                          vertical_align: :middle,
                                          align:  :center

    rows_format = Spreadsheet::Format.new size: 13,
                                          align: :left

    xlsx        = Spreadsheet::Workbook.new
    sheet       = xlsx.create_worksheet
    sheet.name  = 'Invitation codes'

    sheet.row(0).height   = 18
    sheet.row(0).height   = 25
    sheet.column(0).width = 30

    sheet.row(0).concat   ['Invitation Code', 'Role', 'Is used?', 'Used by']

    sheet.row(0).each.with_index { |c, i| sheet.row(0).set_format(i, head_format) }
    @list.uniq.each.with_index(1) do |ic, i|
      sheet.row(i).concat [ic.invitation_code, ic.role, ic.is_invitation_code_used ? 'Yes': 'No', ic.username.presence || '-']
      sheet.row(i).height = 25
      sheet.column(i).width = 30
      sheet.row(i).default_format = rows_format
    end
    @filepath = "tmp/existing-invitation_codes-#{Time.zone.now.to_i}.xlsx"
    
    xlsx.write @filepath
    
    @filepath
  end

  def self.get_invitation_codes(params={})
    @all = WaitList.select('mammoth_wait_lists.id, mammoth_wait_lists.invitation_code, mammoth_wait_lists.role, mammoth_wait_lists.is_invitation_code_used, accounts.id as account_id, accounts.username')
                   .joins('LEFT JOIN users on mammoth_wait_lists.id = users.wait_list_id')
                   .joins('LEFT JOIN accounts on users.account_id = accounts.id')
    
    if params[:selected].present?
      if params[:selected] == 'all'
        @all = @all.where.not(id: params[:unselected])
      else
        @all = @all.where(id: params[:selected])
      end
    end

    if params[:q].present?
      @all = @all.where("mammoth_wait_lists.invitation_code like :q OR mammoth_wait_lists.role like :q OR accounts.username like :q", q: "%#{params[:q].downcase}%")
    end

    @all
  end

end