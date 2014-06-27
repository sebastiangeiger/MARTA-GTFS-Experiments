require 'sequel'
require 'pp'
require 'csv'

# Configuration
DB = Sequel.connect('postgres://localhost/marta')
DATADIR = File.expand_path(File.join(File.dirname(__FILE__), 'google_transit'))

# Models
class Datafile
  def initialize(file_path)
    @file_path = file_path
  end
  def human_readable_name
    File.basename(@file_path, ".txt").
      split("_").
      map {|fragment| fragment.capitalize}.
      join(" ")
  end
  def headers
    CSV.open(@file_path, "r", headers: true) do |csv|
      csv.first.headers
    end
  end
end

# Dumping
txt_files = Dir.glob(DATADIR+"/*.txt").map {|file| Datafile.new(file) }
connected_fields = txt_files.each_with_object({}) do |file,index|
  name = file.human_readable_name
  file.headers.each_with_index do |field,i|
    index[field] ||= []
    index[field] << "#{name} [position #{i}]"
  end
end.select do |field_name,table_names|
  table_names.size > 1
end

puts "The following fields occur in more than one 'table':"
pp connected_fields

