require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song

#=========== # method, returning string, table name===================
  def self.table_name #Song.table_name => Song, "Song", "song", "songs"
    self.to_s.downcase.pluralize
  end
#=========== # method, returning an array of column names===================
  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact #method, getting rid of nil values
  end #can i attach collect here?
#+++++++++++++++++++++++++method, creating  attr_accessor+++++++++++++++++++
#call  column_names class method and add on array iterate method
  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
#===================== metaprogramming =====================================
  def initialize(options={}) #default to empty hash
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end
#==========================================================================
def table_name_for_insert
  self.class.table_name #self.class => Song. #table_name, method i create to make into string.
end
#++++++++#save in instance to the datbase, so instance method,+++++++++++
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
#==========================================================================

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name| #method created earlier & each do
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end
#==========================================================================
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #because of sql auto-increment id, no id column needed
  end
#==========================================================================
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
