require 'sorbet-runtime'

require 'serial_eyesr/serializer'

class Author::Struct < T::Struct
  include T::Struct::ActsAsComparable

  prop :id, Integer
  prop :first_name, String
  prop :last_name, String
  prop :home_country, String
  prop :publishers, T::Array[String]
end

class Author::Serializer < SerialEyesr::Serializer
  STRUCT = Author::Struct
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

RSpec.describe SerialEyesr::Serializer do
  let!(:author) do
    Author.create!(
      first_name: 'Steven',
      last_name: 'Universe',
      address: author_address,
    )
  end

  let(:author_query) { Author.where(id: author.id) }

  let!(:publisher) do
    Publisher.create!(
      name: 'Ronaldo Press',
      address: publisher_address,
    )
  end

  let!(:book) do
    Book.create!(
      author: author,
      title: 'Keep Beach City Weird',
      publisher: publisher,
      published_date: Date.new(2021, 1, 1),
    )
  end

  let!(:author_address) do
    Address.create!(
      street_address_1: '1 Crystal Temple',
      city: 'Beach City',
      state: 'Delmarva',
      country: 'United States of America',
      postal_code: '51343',
    )
  end

  let!(:publisher_address) do
    Address.create!(
      street_address_1: '10 Boardwalk Way',
      city: 'Beach City',
      state: 'Delmarva',
      country: 'United States of America',
      postal_code: '51342',
    )
  end

  def author_hash(author_to_serialize = nil)
    author_to_serialize ||= author
    {
      'id' => author_to_serialize.id,
      'first_name' => author_to_serialize.first_name,
      'last_name' => author_to_serialize.last_name,
      'home_country' => author_to_serialize.address.country,
      'publishers' => author_to_serialize.books.map { |book| book.publisher.name }
    }
  end

  def author_struct(author_to_serialize = nil)
    Author::Struct.new(**author_hash(author_to_serialize)
      .transform_keys(&:to_sym))
  end

  context 'when initialized with no arguments' do
    let(:author_serializer) { Author::Serializer.new }

    describe '#serialize' do
      context 'when given an ActiveRecord instance' do
        it 'serializes to a hash' do
          serializer_result = author_serializer.serialize(author)
          expect(serializer_result).to eq(author_hash)
        end
      end

      context 'when given an ActiveRecord_Relation instance' do
        it 'serializes to an array of hashes' do
          serializer_result = author_serializer.serialize(author_query)
          expect(serializer_result).to contain_exactly(author_hash)
        end
      end
    end

    describe '#serialize_page' do
      context 'when given an ActiveRecord instance' do
        it 'raises' do
          expect { Author::Serializer.new.serialize_page(author) }
            .to raise_error(SerialEyesr::Error)
        end
      end

      context 'when given an ActiveRecord_Relation instance' do
        it 'serializes to an array of hashes' do
          serializer_result = author_serializer.serialize(author_query)
          expect(serializer_result).to contain_exactly(author_hash)
        end

        it 'calls `#includes` on the provided ActiveRecord_Relation instance' do
          expect(author_query)
            .to receive(:includes).with(*Author::Serializer::INCLUDES)
            .and_call_original
          author_serializer.serialize(author_query)
        end
      end
    end
  end

  context 'when initialized with `skip_includes == true`' do
    let(:author_serializer) { Author::Serializer.new(skip_includes: true) }

    describe '#serialize_page' do
      context 'when given an ActiveRecord_Relation instance' do
        it 'serializes to an array of hashes' do
          serializer_result = author_serializer.serialize(author_query)
          expect(serializer_result).to contain_exactly(author_hash)
        end

        it 'does not call `#includes` on the provided ActiveRecord_Relation '\
           'instance' do
          expect(author_query)
            .not_to receive(:includes).with(*Author::Serializer::INCLUDES)
            .and_call_original
          author_serializer.serialize(author_query)
        end
      end
    end
  end

  context 'when initialized with `to_hash == false`' do
    let(:author_serializer) { Author::Serializer.new(to_hash: false) }

    describe '#serialize' do
      context 'when given an ActiveRecord instance' do
        it 'serializes to a struct' do
          serializer_result = author_serializer.serialize(author)
          expect(serializer_result).to eq(author_struct)
        end
      end

      context 'when given an ActiveRecord_Relation instance' do
        it 'serializes to an array of structs' do
          serializer_result = author_serializer.serialize(author_query)
          expect(serializer_result).to contain_exactly(author_struct)
        end
      end
    end
  end

  context 'when defaulted to TO_HASH == false' do
    class Author::StructSerializer < Author::Serializer
      TO_HASH = false
    end

    context 'when initialized with no arguments' do
      let(:author_serializer) { Author::StructSerializer.new }

      describe '#serialize' do
        context 'when given an ActiveRecord instance' do
          it 'serializes to a struct' do
            serializer_result = author_serializer.serialize(author)
            expect(serializer_result).to eq(author_struct)
          end
        end

        context 'when given an ActiveRecord_Relation instance' do
          it 'serializes to an array of structs' do
            serializer_result = author_serializer.serialize(author_query)
            expect(serializer_result).to contain_exactly(author_struct)
          end
        end
      end
      describe '#serialize_page' do
        context 'when given an ActiveRecord_Relation instance' do
          it 'serializes to an array of structs' do
            serializer_result = author_serializer.serialize(author_query)
            expect(serializer_result).to contain_exactly(author_struct)
          end
        end
      end
    end

    context 'when initialized with `to_hash == true`' do
      let(:author_serializer) { Author::StructSerializer.new(to_hash: true) }

      describe '#serialize' do
        context 'when given an ActiveRecord instance' do
          it 'serializes to a hash' do
            serializer_result = author_serializer.serialize(author)
            expect(serializer_result).to eq(author_hash)
          end
        end

        context 'when given an ActiveRecord_Relation instance' do
          it 'serializes to an array of hashes' do
            serializer_result = author_serializer.serialize(author_query)
            expect(serializer_result).to contain_exactly(author_hash)
          end
        end
      end
      describe '#serialize_page' do
        context 'when given an ActiveRecord_Relation instance' do
          it 'serializes to an array of hashes' do
            serializer_result = author_serializer.serialize(author_query)
            expect(serializer_result).to contain_exactly(author_hash)
          end
        end
      end
    end
  end
end
