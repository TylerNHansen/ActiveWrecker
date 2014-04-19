require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    where_str = params.map { |key, val| ["#{key} = ?"] }.join(' AND ')
    parse_all(DBConnection.execute("
    SELECT
    #{table_name}.*
    FROM
    #{table_name}
    WHERE
    #{where_str}
    ", *params.values))
  end
end

class SQLObject
  extend Searchable
end
