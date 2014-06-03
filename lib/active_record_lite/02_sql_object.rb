require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map { |data| new(data) }
  end
end

class SQLObject < MassObject
  def self.columns
    @columns ||=
    DBConnection.execute2("SELECT * FROM #{table_name}").first.map(&:to_sym)

    if !@col_methods_initialized
      @col_methods_initialized = true
      define_column_methods
    end

    @columns
  end

  def self.table_name=(table_name = nil)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.pluralize.underscore
    @table_name
  end

  def self.all
    parse_all(DBConnection.execute("
    SELECT
      #{table_name}.*
    FROM
      #{table_name}
    "))
  end

  def self.find(id)
    self.new(DBConnection.execute("
    SELECT
    #{table_name}.*
    FROM
    #{table_name}
    WHERE
    id = #{id}
    LIMIT 1
    ").first
    )
  end

  def columns
    self.class.columns
  end

  def table_name
    self.class.table_name
  end

  def self.define_column_methods
    # p self
    columns.each do |col|
      self.send(:define_method, (col)) { @attributes[col] }
      self.send(:define_method, ("#{col}=")) { |value| @attributes[col] = value }
    end
  end

  def attributes
    @attributes ||= Hash.new
  end

  def insert
    cols = columns.reject{ |el| el == :id }
    col_str = "( #{cols.join(', ')} )"
    question_str = col_str.gsub(/\w+/, '?')

    DBConnection.execute("
    INSERT INTO
    #{table_name} #{col_str}
    VALUES
    #{question_str}
    ", *non_id_values)

    attributes[:id] = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    attrs = Hash.new
    columns.each {|col| attrs[col] = nil}
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      fail "unknown attribute #{attr_name}" unless self.class.columns.include?(attr_name)
      attrs[attr_name] = value
    end
    @attributes = attrs
    self
  end

  def save
    unless attributes[:id].nil?
      update
    else
      insert
    end
  end

  def update
    set_str = attributes.map { |key, val| "#{key} = ?"}.join(', ')

    DBConnection.execute("
    UPDATE
    #{table_name}
    SET
    #{set_str}
    WHERE
    id = #{attributes[:id]}
    ", *attribute_values)
  end

  def attribute_values
    attributes.values
  end
  def non_id_values
    attributes.reject{|k,v| k == :id}.map(&:last)
  end
end
