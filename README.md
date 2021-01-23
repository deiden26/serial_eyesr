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
  class AuthorStruct < T::Struct
    prop :id, Integer
    prop :first_name, String
    prop :last_name, String
    prop :home_country, String
    prop :publishers, T::Array[String]
  end

  STRUCT = AuthorStruct
  PAGE_SIZE = 20
  ACTIVE_RECORD = Author
  INCLUDES = [
    :address,
    { books: :publisher },
  ].freeze

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
AuthorSerializer.new(Author.first).serialize
# Serialize active record queries
AuthorSerializer.new(Author.all).serialize
# Serialize active record queries and skip the default includes
AuthorSerializer.new(Author.all).serialize(skip_includes: true)
# Serialize arrays of active record instances
AuthorSerializer.new(Author.all.to_a).serialize
# Serialize active record queries by the page using the default page size
AuthorSerializer.new(Author.all).serialize_page
# Serialize active record queries by the page with an offset
AuthorSerializer.new(Author.all).serialize_page(offset: 20)
# Serialize active record queries by the page and override the page size
AuthorSerializer.new(Author.all).serialize_page(page_size: 10)
# Serialize active record queries by the page and skip the default includes
AuthorSerializer.new(Author.all).serialize_page(skip_includes: true)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/deiden26/serial_eyesr.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
