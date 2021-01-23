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

### Example

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/deiden26/serial_eyesr.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
