require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
      ATTRIBUTES = { 
        :ID => "iNTEGER"
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true
    table_columns = DB[:conn].execute("PRAGMA table_info(#{table_name})")
    column_names = []
    table_columns.each do |column|
      column_names << column["name"]
    end
    column_names.compact
  end
  
  def initialize(attributes = {})
    attributes.each {|key, value| self.send("#{key}=", value)}
  end
  
  
   def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if { |column| column == "id" }.join(", ")
  end
  
  def values_for_insert
    values = []
    self.class.column_names.map do |column|
      values << "'#{send(column)}'" unless send(column).nil?
    end
    values.join(", ")
  end
  
  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name)
  end
  
   def self.find_by(attribute_hash)
    sql = <<-SQL
      SELECT * FROM #{self.table_name}
      WHERE #{attribute_hash.keys.first} = ?
    SQL
    DB[:conn].execute(sql, attribute_hash.values.first)
    end
end