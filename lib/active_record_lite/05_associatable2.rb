require_relative '04_associatable'
require 'debugger'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      thru_opts = self.class.assoc_options[through_name]
      source_opts = thru_opts.model_class.assoc_options[source_name]
      p thru_opts
      p source_opts
#       source_opts.model_class.joins(thru_opts.model_class)
      target_table = thru_opts.table_name
      thru_table = source_opts.table_name
      join_fk_name = source_opts.foreign_key
      join_pk_name = thru_opts.primary_key
      self_fk_name = thru_opts.foreign_key
      self_pk = self.send(self_fk_name)
      temp = "
        SELECT
        #{thru_table}.*
        FROM
        #{target_table}
        JOIN
        #{thru_table}
        ON
        #{target_table}.#{join_fk_name}=#{thru_table}.#{join_pk_name}
        WHERE
        #{target_table}.#{join_pk_name}=#{self_pk}
        "

      source_opts.model_class.new(DBConnection.execute(temp).first)

    end
  end
end
