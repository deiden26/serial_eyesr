require_relative 'allowed_types'

# A serializer service that turns queries into JSON Ready Hashes
#
# Design choices
# - Use limit and offset pagination to support pre-sorted queries
# - Use Sorbet to define the output structure and types
# - Use inheritence to abstract boilerplate code and allow for customization
#
# @example
#  class Author::Serializer < SerialEyesr::Serializer
#    class AuthorStruct < T::Struct
#      prop :id, Integer
#      prop :first_name, String
#      prop :last_name, String
#      prop :home_country, String
#      prop :publishers, T::Array[String]
#    end
#
#    STRUCT = AuthorStruct
#    PAGE_SIZE = 20
#    ACTIVE_RECORD = Author
#    TO_HASH = false
#    INCLUDES = [
#      :address,
#      { books: :publisher },
#    ]
#
#    def home_country(author)
#      author.address.country
#    end
#
#    def publishers(author)
#      author.books.map { |book| book.publisher.name }
#    end
#  end
#
# @example
#  Author::Serializer.new.serialize(Author.first)
#  Author::Serializer.new.serialize(Author.all.to_a)
#  Author::Serializer.new.serialize(Author.all)
#  Author::Serializer.new(skip_includes: true).serialize(Author.all)
#  Author::Serializer.new(to_hash: true).serialize(Author.all)
#  Author::Serializer.new.serialize_page(Author.all)
#  Author::Serializer.new.serialize_page(Author.all, offset: 20, page_size: 10)
#
class SerialEyesr::Serializer
  STRUCT = nil
  ACTIVE_RECORD = nil
  INCLUDES = nil
  TO_HASH = true
  PAGE_SIZE = 20

  def initialize(skip_includes: false, to_hash: nil)
    @struct = self.class::STRUCT
    @active_record = self.class::ACTIVE_RECORD
    @includes = self.class::INCLUDES

    validate_struct
    validate_active_record
    validate_includes

    # rubocop:disable Style/ColonMethodCall
    @active_record_relation = @active_record::const_get('ActiveRecord_Relation')
    # rubocop:enable Style/ColonMethodCall
    @skip_includes = skip_includes
    @to_hash = if to_hash.nil?
                 self.class::TO_HASH
               else
                 to_hash
               end
    @default_page_size = self.class::PAGE_SIZE
  end

  def serialize(record)
    case record
    when @active_record
      construct_from_active_record(record)
    when Array
      record.map do |record_instance|
        construct_from_active_record(record_instance)
      end
    when @active_record_relation
      construct_from_query(record)
    else
      raise Error, "Can only serialize a(n) #{@active_record}, an array of "\
        "#{@active_record}s, or a query for #{@active_record}s. #{record} is "\
        'not the correct type.'
    end
  end

  def serialize_page(record, offset: 0, page_size: nil)
    unless record.instance_of?(@active_record_relation)
      raise SerialEyesr::Error, 'Can only serialize a query for '\
        "#{@active_record} by the page. #{record} is not the correct type."
    end

    page_size ||= @default_page_size

    query = record.offset(offset).limit(page_size)
    serialize(query)
  end

  private

  def validate_struct
    unless @struct < T::Struct
      raise SerialEyesr::Error, 'Provide a T::Struct subclass as the STRUCT '\
        "for #{self.class}. Received #{@struct} instead."
    end

    @struct.props.each { |prop, config| validate_prop(prop, config) }
  end

  def validate_prop(prop, config)
    invalid_type = nil
    if config[:array]
      invalid_type = config[:array] unless in_allowed_types?(config[:array])
    elsif !in_allowed_types?(config[:type])
      invalid_type = config[:type]
    end

    return unless invalid_type

    raise Error, "The '#{prop}' prop in #{self.class} is an invalid "\
      "type: #{invalid_type}"
  end

  def in_allowed_types?(type)
    ALLOWED_TYPES.any? { |allowed_type| type <= allowed_type }
  end

  def validate_active_record
    return if @active_record < ActiveRecord::Base

    raise Error, 'Provide an ActiveRecord::Base subclass as the '\
      "ACTIVE_RECORD for #{self.class}. Received #{@active_record} instead."
  end

  def validate_includes
    return if @includes.nil? ||
      (@includes.is_a?(Array) && all_leaves_below_symbols(@includes))

    raise Error, 'Provide an array of symbols, hashes, or more arrays for '\
      "the INCLUDES of #{self.class}"
  end

  def all_leaves_below_symbols(include_tree)
    case include_tree
    when Symbol
      true
    when Hash
      include_tree.all? do |key, value|
        key.is_a?(Symbol) && all_leaves_below_symbols(value)
      end
    when Array
      include_tree.all? do |value|
        all_leaves_below_symbols(value)
      end
    else
      false
    end
  end

  def construct_from_query(query)
    query = if !@skip_includes && @includes
              query.includes(*@includes)
            else
              query
            end
    query.find_each.map do |record_instance|
      construct_from_active_record(record_instance)
    end
  end

  def construct_from_active_record(record)
    prop_values = {}
    @struct.props.each_key do |prop|
      prop_values[prop] =
        if respond_to?(prop)
          send(prop, record)
        else
          record.send(prop)
        end
    end
    struct_instance = @struct.new(prop_values)
    if @to_hash
      struct_instance.serialize
    else
      struct_instance
    end
  end
end
