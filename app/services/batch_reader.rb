class BatchReader

  EXTENSIONS = ['csv','xls','xlsx','ods']
  FILE_FIELDS = [:file,:label,:offset,:skip_transcoding,:absolute_location,:date_digitized]
  SKIP_FIELDS = [:collection]

  def read(batch, file_location)
    begin
      spreadsheet = Roo::Spreadsheet.open(file_location)

      batch.name = spreadsheet.row(spreadsheet.first_row)[0] # TODO add name to batch DB
      batch.submitter_email = spreadsheet.row(spreadsheet.first_row)[1]
      # batch.admin_set_id = admin_set_id
      batch.source_location = ''  # TODO what value?

      header_row = spreadsheet.row(spreadsheet.first_row + 1)
      field_names = header_row.collect { |field|
        field.to_s.downcase.gsub(/\s/,'_').strip.to_sym
      }
      batch.entires = create_entries!(spreadsheet, field_names)
      
      batch.status = 'accepted'
    rescue Exception => err
      batch.error = err
      error! "Invalid manifest file: #{err.message}"
    end
  end

  private
  
  def create_entries!(spreadsheet, field_names)
    first = spreadsheet.first_row + 2
    last = spreadsheet.last_row
    first.upto(last) do |index|
      opts = {
          :publish => false,
          :hidden  => false
      }

      values = spreadsheet.row(index).collect do |val|
        (val.is_a?(Float) and (val == val.to_i)) ? val.to_i.to_s : val.to_s
      end
      content=[]

      fields = Hash.new { |h,k| h[k] = [] }
      field_names.each_with_index do |f,i|
        unless f.blank? || SKIP_FIELDS.include?(f) || values[i].blank?
          if FILE_FIELDS.include?(f)
            content << {} if f == :file
            content.last[f] = f == :skip_transcoding ? true?(values[i]) : values[i]
          else
            fields[f] << values[i]
          end
        end
      end

      opts.keys.each { |opt|
        val = Array(fields.delete(opt)).first.to_s
        if opts[opt].is_a?(TrueClass) or opts[opt].is_a?(FalseClass)
          opts[opt] = true?(val)
        else
          opts[opt] = val
        end
      }
      files = content.each { |file| file[:file] = path_to(file[:file]) }
      entries << Entry.new(fields.select { |f| !FILE_FIELDS.include?(f) }, files, opts, index, self)
    end
  end
  
end