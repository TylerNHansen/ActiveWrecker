require_relative '04_associatable'
require 'debugger'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      thru_opts = self.class.assoc_options[through_name]
      source_opts = thru_opts.model_class.assoc_options[source_name]
      source_opts.model_class.joins(thru_opts.model_class)
    end
  end
end
