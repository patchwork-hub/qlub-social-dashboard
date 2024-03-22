require 'spreadsheet'

class Account < ApplicationRecord
  has_one :user, inverse_of: :account
  has_many :statuses, inverse_of: :account
  has_many :global_filters, inverse_of: :account, dependent: :nullify

  validates :username, uniqueness: true, presence: true

  before_create :generate_keys

  def self.to_xlsx(params={})
    @list = self.get_accounts(params)

    Spreadsheet.client_encoding = 'UTF-8'

    head_format = Spreadsheet::Format.new size:    14,
                                          weight: :bold,
                                          vertical_align: :middle,
                                          align:  :center

    rows_format = Spreadsheet::Format.new size: 13,
                                          align: :left

    xlsx        = Spreadsheet::Workbook.new
    sheet       = xlsx.create_worksheet
    sheet.name  = 'Users'

    sheet.row(0).height   = 18
    sheet.row(0).height   = 25
    sheet.column(0).width = 30

    sheet.row(0).concat   ['Email address', 'Username', 'Display name', 'Phone number', 'Role', 'Primary community']

    sheet.row(0).each.with_index { |c, i| sheet.row(0).set_format(i, head_format) }
    @list.uniq.each.with_index(1) do |acc, i|
      email = acc.phone.present? ? '-' : acc.email
      sheet.row(i).concat [email, acc.username, acc.display_name || '-', acc.phone || '-', acc.user_role || '-', acc.community_name || '-']
      sheet.row(i).height = 25
      sheet.column(i).width = 30
      sheet.row(i).default_format = rows_format
    end
    @filepath = "tmp/users-list-#{Time.zone.now.to_i}.xlsx"
    
    xlsx.write @filepath
    
    @filepath
  end

  def self.get_accounts(params={})
    excluded_ids = UserRole.where(name: ['community-admin', 'rss-account']).pluck(:id)
    @all        = User.where.not(role_id: excluded_ids).or(User.where(role_id: nil))
                       .select('users.id, users.phone, users.email, accounts.id as account_id, accounts.display_name, accounts.username, accounts.created_at as registered_at, 
                          mammoth_wait_lists.role as user_role, mammoth_communities.name as community_name
                        ')
                       .joins('LEFT JOIN accounts ON users.account_id = accounts.id')
                       .joins('LEFT JOIN mammoth_wait_lists ON mammoth_wait_lists.id = users.wait_list_id')
                       .joins('LEFT JOIN 
                          ( 
                            select id, user_id, community_id, is_primary 
                            from mammoth_communities_users
                            where is_primary = true
                          ) cu
                          on cu.user_id = users.id
                        ') 
                       .joins('LEFT JOIN mammoth_communities ON mammoth_communities.id = cu.community_id')

    if params[:selected].present?
      if params[:selected] == 'all'
        @all = @all.where.not(id: params[:unselected])
      else
        @all = @all.where(id: params[:selected])
      end
    end

    if params[:q].present?
      @all = @all.where("lower(accounts.display_name) like :q
                        OR lower(accounts.username) like :q
                        OR lower(users.email) like :q
                        OR lower(users.phone) like :q
                        OR lower(mammoth_wait_lists.role) like :q
                        OR lower(mammoth_communities.name) like :q",
                        q: "%#{params[:q].downcase}%"
                      )
    end

    @all
  end

  private

  def generate_keys
    return unless private_key.blank? && public_key.blank?

    keypair = OpenSSL::PKey::RSA.new(2048)
    self.private_key = keypair.to_pem
    self.public_key  = keypair.public_key.to_pem
  end

end


