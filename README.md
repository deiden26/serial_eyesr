# SerialEyesr

Serialeyesr is a serializing framework built to put
typed, performative serialization on rails. Configure the serialized
fields, types, default page size, related includes, and active record
with a clear, declarative syntax that makes N+1 queries difficult to produce.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'serial_eyesr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install serial_eyesr

## Usage

### Example Serializer

```ruby
class Author::Serializer < SerialEyesr::Serializer
  # Sorbet structs can be defined in the class or externally
  class AuthorStruct < T::Struct
    prop :id, Integer
    prop :first_name, String
    prop :last_name, String
    prop :home_country, String
    prop :publishers, T::Array[String]
  end

  # Provide the typed struct to use as the field list for serialization
  STRUCT = AuthorStruct
  # Set the active record that will be serialized for validation purposes
  ACTIVE_RECORD = Author
  # Optionally list related fields to include
  INCLUDES = [
    :address,
    { books: :publisher },
  ]
  # Defaults to 20
  PAGE_SIZE = 25
  # Defaults to true. Returns the Sorbet struct itself when false. Returns the
  # result of the `serialize` Sorbet struct method when true.
  TO_HASH = false

  # When a method exists on the serializer matching a field name, it is used to
  # serialize the field. Otherwise, the field name is sent to each active
  # record instance.
  def home_country(author)
    author.address.country
  end

  def publishers(author)
    author.books.map { |book| book.publisher.name }
  end
end
```

### Example Usage

```ruby
# Serialize active record instances directly
Author::Serializer.new.serialize(Author.first)

# Serialize arrays of active record instances
Author::Serializer.new.serialize(Author.all.to_a)

# Serialize active record queries
Author::Serializer.new.serialize(Author.all)

# Force serialization to hashes (or to structs)
Author::Serializer.new(to_hash: true).serialize(Author.all)

# Skip the default includes when serializing queries
Author::Serializer.new(skip_includes: true).serialize(Author.all)

# Paginate queries to a default page size
Author::Serializer.new.serialize_page(Author.all)

# Offset the query before paginating it
Author::Serializer.new.serialize_page(Author.all, offset: 20)

# Use a custom page size when paginating
Author::Serializer.new.serialize_page(Author.all, page_size: 10)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/deiden26/serial_eyesr.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
