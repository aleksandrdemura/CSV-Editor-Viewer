# csv_editor.rb
require 'csv'

class CSVEditor
  def initialize(filename = nil)
    @filename = filename
    @headers = []
    @rows = []
    if filename && File.exist?(filename)
      load(filename)
    elsif filename
      create_empty
    else
      create_empty
    end
  end

  def load(filename)
    data = CSV.read(filename)
    return if data.empty?
    @headers = data[0].map(&:strip)
    @rows = data[1..-1].map { |row| row.map(&:strip) } if data.size > 1
  end

  def save(filename = nil)
    filename ||= @filename
    if filename.nil? || filename.empty?
      print "Enter filename to save: "
      filename = gets.chomp.strip
      filename += '.csv' unless filename.end_with?('.csv')
    end
    CSV.open(filename, 'w') do |csv|
      csv << @headers
      @rows.each { |row| csv << row }
    end
    puts "Saved."
  end

  def create_empty
    puts "Creating new CSV file."
    print "Enter column headers (comma-separated): "
    input = gets.chomp.strip
    @headers = input.empty? ? ['Column1', 'Column2', 'Column3'] : input.split(',').map(&:strip)
    @rows = []
    save(@filename || 'new.csv')
  end

  def display
    if @headers.empty?
      puts "No data loaded."
      return
    end
    col_widths = @headers.map(&:length)
    @rows.each do |row|
      row.each_with_index do |cell, i|
        col_widths[i] = cell.length if i < col_widths.length && cell.length > col_widths[i]
      end
    end
    sep = ' | '
    puts
    puts @headers.each_with_index.map { |h, i| h.ljust(col_widths[i]) }.join(sep)
    puts '-' * col_widths.sum + ('-' * (col_widths.length - 1) * sep.length)
    @rows.each do |row|
      cells = @headers.each_with_index.map { |_, i| (row[i] || '').ljust(col_widths[i]) }
      puts cells.join(sep)
    end
  end

  def add_row
    if @headers.empty?
      puts "No headers defined. Please add columns first."
      return
    end
    row = @headers.map do |h|
      print "Enter value for '#{h}': "
      gets.chomp.strip
    end
    @rows << row
    puts "Row added."
  end

  def edit_cell
    display
    print "Enter row index (1-based): "
    row_idx = gets.chomp.to_i - 1
    if row_idx < 0 || row_idx >= @rows.size
      puts "Invalid row index."
      return
    end
    puts "Columns: #{@headers.join(', ')}"
    print "Enter column name: "
    col_name = gets.chomp.strip
    col_idx = @headers.index(col_name)
    if col_idx.nil?
      puts "Column not found."
      return
    end
    print "Enter new value for '#{col_name}': "
    new_val = gets.chomp.strip
    @rows[row_idx][col_idx] = new_val
    puts "Cell updated."
  end

  def delete_row
    display
    print "Enter row index to delete (1-based): "
    row_idx = gets.chomp.to_i - 1
    if row_idx < 0 || row_idx >= @rows.size
      puts "Invalid row index."
      return
    end
    @rows.delete_at(row_idx)
    puts "Row deleted."
  end

  def filter_rows
    if @rows.empty?
      puts "No rows to filter."
      return
    end
    puts "Columns: #{@headers.join(', ')}"
    print "Enter column name to filter: "
    col_name = gets.chomp.strip
    col_idx = @headers.index(col_name)
    if col_idx.nil?
      puts "Column not found."
      return
    end
    print "Enter value to match: "
    value = gets.chomp.strip
    print "Case-sensitive? (y/n): "
    case_sensitive = gets.chomp.strip.downcase == 'y'
    filtered = @rows.select do |row|
      col_idx < row.size &&
      (case_sensitive ? row[col_idx] == value : row[col_idx].downcase == value.downcase)
    end
    if filtered.empty?
      puts "No matching rows."
    else
      old_rows = @rows
      @rows = filtered
      display
      @rows = old_rows
    end
  end

  def sort_rows
    if @rows.empty?
      puts "No rows to sort."
      return
    end
    puts "Columns: #{@headers.join(', ')}"
    print "Enter column name to sort by: "
    col_name = gets.chomp.strip
    col_idx = @headers.index(col_name)
    if col_idx.nil?
      puts "Column not found."
      return
    end
    print "Sort descending? (y/n): "
    reverse = gets.chomp.strip.downcase == 'y'
    @rows.sort_by! { |row| col_idx < row.size ? row[col_idx] : '' }
    @rows.reverse! if reverse
    puts "Rows sorted."
  end

  def add_column
    print "Enter new column name: "
    col_name = gets.chomp.strip
    if col_name.empty?
      puts "Invalid name."
      return
    end
    if @headers.include?(col_name)
      puts "Column already exists."
      return
    end
    print "Enter default value for existing rows (leave empty for empty string): "
    default_val = gets.chomp.strip
    @headers << col_name
    @rows.each { |row| row << default_val }
    puts "Column added."
  end

  def remove_column
    if @headers.empty?
      puts "No columns to remove."
      return
    end
    puts "Columns: #{@headers.join(', ')}"
    print "Enter column name to remove: "
    col_name = gets.chomp.strip
    col_idx = @headers.index(col_name)
    if col_idx.nil?
      puts "Column not found."
      return
    end
    @headers.delete_at(col_idx)
    @rows.each { |row| row.delete_at(col_idx) if col_idx < row.size }
    puts "Column removed."
  end

  def summary
    puts "File: #{@filename || '(new)'}"
    puts "Rows: #{@rows.size}"
    puts "Columns: #{@headers.size}"
    puts "Headers: #{@headers.join(', ')}" unless @headers.empty?
  end

  def run
    puts "=== CSV Editor/Viewer ==="
    if @filename
      puts "Loaded: #{@filename} (#{@rows.size} rows, #{@headers.size} columns)"
    else
      puts "No file loaded."
    end
    loop do
      puts "\nMenu:"
      puts "1. View table"
      puts "2. Add row"
      puts "3. Edit cell"
      puts "4. Delete row"
      puts "5. Filter rows"
      puts "6. Sort rows"
      puts "7. Add column"
      puts "8. Remove column"
      puts "9. Export / Save"
      puts "10. Show summary"
      puts "11. Exit"
      print "Choose: "
      choice = gets.chomp.strip
      case choice
      when '1' then display
      when '2' then add_row
      when '3' then edit_cell
      when '4' then delete_row
      when '5' then filter_rows
      when '6' then sort_rows
      when '7' then add_column
      when '8' then remove_column
      when '9' then save
      when '10' then summary
      when '11'
        print "Save before exit? (y/n): "
        save if gets.chomp.strip.downcase == 'y'
        puts "Goodbye!"
        break
      else puts "Invalid choice."
      end
    end
  end
end

filename = ARGV.first
editor = CSVEditor.new(filename)
editor.run
