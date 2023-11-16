require "google_drive"
session = GoogleDrive::Session.from_config("config.json")
$ws = session.spreadsheet_by_key("1eKDpfAKD-kfEOHJ_iTJbILYIIMULoZPcwmaf51lJDpU").worksheets[0]

class Table
  include Enumerable
  attr_accessor :table_values, :headers

  def initialize
    @worksheet = $ws
    @table_values = filter_non_empty_rows(@worksheet.rows)
    @headers = @table_values.shift if @table_values.any?
  end

  def filter_non_empty_rows(rows)
    rows.reject do |row|
      row.all? { |cell| cell.nil? || cell.to_s.strip.empty? } ||
      row.any? { |cell| cell.to_s.downcase.include?('total') || cell.to_s.downcase.include?('subtotal') }
    end
  end

  def print_table
    puts "Headers: #{headers}"

    @table_values.each do |row|
      puts "Row: #{row}"
    end
  end

  def row(index)
    puts "Row #{index}: #{@table_values[index-1]}"
  end

  def each(&_block)
    yield(worksheet[1, 1])
  end

  def [](header)
    header_index = headers.index(header.to_s)

    return nil unless header_index
      
    column = @worksheet.rows[1..-1].map { |row| row[header_index] }
    Column.new(column, @worksheet, header_index, @table_values.map { |row| row[header_index] })
    
    #puts "#{header}: #{values}"
  end

  def method_missing(method_name, *arg)
    header_index = headers.index(method_name.to_s)
    
    return nil unless header_index
  
    column = @worksheet.rows[1..-1].map { |row| row[header_index].to_i }
    Column.new(column, @worksheet, header_index, @table_values.map { |row| row[header_index] })
  end

  def plus(table)
    return unless !headers_match?(table)
    @table_values.each_with_index do |row, i|
      new_row = row.map.with_index do |cell, j|
        cell.to_f + table.table_values[i][j].to_f
      end
      @table_values[i] = new_row
    end
  end

  def minus(table)
    return unless !headers_match?(table)
    @table_values.each_with_index do |row, i|
      new_row = row.map.with_index do |cell, j|
        cell.to_f - table.table_values[i][j].to_f
      end
      @table_values[i] = new_row
    end
  end

  def match?(table)
   self.headers == table.headers
  end

end


class Column
  attr_accessor :column, :worksheet, :header_index

  def initialize(column, worksheet, header_index, values)
    @column = column
    @worksheet = worksheet
    @header_index = header_index
    @values = values
  end

  def to_s
    @values.inspect
  end

  def [](index)
    
    puts "#{@values[index - 1]}"
  end

  def []=(index, new_value)
    @values[index - 1] = new_value
  end

  def sum
    column.compact.sum
  end

  def avg
    values = column.compact
    non_zero_values = values.reject { |value| value == 0 }
    length_without_zeros = non_zero_values.length.to_f
    values.empty? ? nil : values.sum / length_without_zeros
  end

  def method_missing(method_name, *args)
    row_index = column.index(method_name.to_s)

    return nil unless row_index

    puts "#{worksheet.rows[row_index + 1]}"
  end

  #dalmatinac
end

def main

  my_table = Table.new
  my_table.print_table

  my_table.row(1)
  val = my_table["Prvakolona"]
  puts val
  my_table["Prvakolona"][1]
  my_table["Prvakolona"][1]=2
  
  val = my_table.Prvakolona
  puts val

  puts my_table.Prvakolona.sum

  puts my_table.Prvakolona.avg

  #t.indeks.rn2310
  my_table.Prvakolona.cetiri

  my_table.plus(my_table)
  my_table.print_table
  my_table.minus(my_table)
  my_table.print_table

end

main