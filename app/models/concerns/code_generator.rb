require 'spreadsheet'

module CodeGenerator
  CODES = [].uniq
  LIMIT = ''

	extend ActiveSupport::Concern

	included do

	end

  class_methods do

    # role can be "contributor" and "end-user"
    def export_codes(role: 'end-user', limit: 0)
      LIMIT.replace limit.to_s unless LIMIT.present?

      generate_code_in_batch(role, limit)
      filter_duplicates(role, limit)
      @filepath
    end

    def filter_duplicates(role, limit)
      existing_codes = self.pluck(:invitation_code)
      tmp = CODES.uniq
      puts "Rejecting duplicate codes \n"
      tmp = tmp - existing_codes
      CODES.replace tmp.uniq
      gap = LIMIT.to_i - CODES.length
      if  gap == 0
        puts "Inserting into database \n"
        CODES.each do |c|
          create(invitation_code: c, role: role)
        end

        to_xlsx_for_new(role)
        
        # reset constants
        CODES.replace []
        LIMIT.replace ''
        puts "Done!!"
      else
        export_codes(role: role, limit: gap)
      end
    end

    def generate_code_in_batch(role, limit)
      limit.times.each do
        CODES << generate_code
      end
    end

    def generate_code
      combile = (1..9).to_a + ('a'..'z').to_a
      uniq_code = (0...4).collect { combile[Kernel.rand(combile.length)] }.join
    end

    def to_xlsx_for_new(role)
      puts "Writing excel sheet\n"
      Spreadsheet.client_encoding = 'UTF-8'

      head_format = Spreadsheet::Format.new size:    14,
                                            weight: :bold,
                                            vertical_align: :middle,
                                            align:  :center

      rows_format = Spreadsheet::Format.new size: 13,
                                            align: :center

      xlsx        = Spreadsheet::Workbook.new
      sheet       = xlsx.create_worksheet
      sheet.name  = 'Invitation codes'

      sheet.row(0).height   = 18
      sheet.row(0).height   = 25
      sheet.column(0).width = 30

      sheet.row(0).concat   ['Invitation Code', 'Role', 'Is used?']

      sheet.row(0).each.with_index { |c, i| sheet.row(0).set_format(i, head_format) }
      CODES.each.with_index(1) do |c, i|
        sheet.row(i).concat [c, role, 'No']
        sheet.row(i).height = 25
        sheet.column(i).width = 30
        sheet.row(i).default_format = rows_format
      end
      @filepath = "tmp/#{role}-invitation-codes-#{Time.zone.now.to_i}.xlsx"
      xlsx.write @filepath
      puts "Excel is ready!! \n"
      return
    end

  end
end