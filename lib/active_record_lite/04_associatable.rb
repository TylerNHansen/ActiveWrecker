require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  ActiveSupport::Inflector.inflections do |inflect|
    inflect.irregular 'human', 'humans'
  end

  def model_class
    class_name.constantize
  end

  def table_name
    class_name.pluralize.underscore
  end
end

class BelongsToOptions < AssocOptions



  def initialize(name, options = {})

    defaults = {
      foreign_key: "#{name.to_s.underscore}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.camelcase
      }

    options = defaults.merge(options)
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      foreign_key: "#{self_class_name.underscore}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.camelcase.singularize
    }
    options = defaults.merge(options)
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
    @primary_key = options[:primary_key]
    self.class.assoc_options[name, options]
  end
end

module Associatable
  # Phase IVb
  def assoc_options
    @assoc_options ||= Hash.new
  end

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      fk_val = self.attributes[options.foreign_key]
      options.model_class.where(options.primary_key => fk_val).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      pk_val = self.attributes[options.primary_key]
      options.model_class.where(options.foreign_key => pk_val )
    end
  end


end

class SQLObject
  extend Associatable
end
