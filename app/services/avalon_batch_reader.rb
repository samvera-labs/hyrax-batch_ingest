class AvalonBatchReader

  FILE_FIELDS = [:file,:label,:offset,:skip_transcoding,:absolute_location,:date_digitized]
  SKIP_FIELDS = [:collection]

  def initialize(source_location)
    @source_location = source_location
    @read = false
    @name = nil
    @submitter_email = nil
    @batch_items = nil
  end

  # TODO refer to Issue #58 to decide if we will add/populate this field
  def name
    read unless @read
    @name
  end

  def submitter_email
    read unless @read
    @submitter_email
  end

  def batch_items
    read unless @read
    @batch_items
  end

  private
  
  def read()
    begin
      spreadsheet = Roo::Spreadsheet.open(source_location)
      read_name_email(spreadsheet)
      read_batch_items(spreadsheet, field_names(spreadsheet))
    rescue Exception => err
      raise ReaderError "Invalid manifest file: #{err.message}"
    ensure
      @read = true
    end
  end

  def read_name_email(spreadsheet)
    @name = spreadsheet.row(spreadsheet.first_row)[0]
    @submitter_email = spreadsheet.row(spreadsheet.first_row)[1]
  end

  def read_batch_items(spreadsheet, field_names)
    @batch_items = []
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
      @batch_items << create_batch_item(index, fields, files)
    end
  end

  def create_batch_item(index, fields, files)
      batch_item = BatchItem.new
      batch_item.id_within_batch = index.to_s
      batch_item.source_location = @source_location
      batch_item.status = :initialized

      all_fields = fields.select { |f| !FILE_FIELDS.include?(f) }
      all_fields << { :files => files }
      batch_item.source_data = all_fields.to_json

      batch_item
  end

  def field_names(spreadsheet)
    header_row = spreadsheet.row(spreadsheet.first_row + 1)
    field_names = header_row.collect { |field|
      field.to_s.downcase.gsub(/\s/,'_').strip.to_sym
    }
  end

  def true?(value)
    not (value.to_s =~ /^(y(es)?|t(rue)?)$/i).nil?
  end
end