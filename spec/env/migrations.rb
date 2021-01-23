require 'active_record'

SuperClass = if ActiveRecord::VERSION::MAJOR >= 5
               ActiveRecord::Migration[
                 "#{ActiveRecord::VERSION::MAJOR}."\
                 "#{ActiveRecord::VERSION::MINOR}".to_f
               ]
             else
               ActiveRecord::Migration
             end

class CreateAuthorsTable < SuperClass
  def change
    create_table :authors do |t|
      t.column :first_name, :string, { null: false }
      t.column :last_name, :string, { null: false }
      t.belongs_to :address, { foreign_key: true }
      t.timestamps
    end
  end
end

class CreatePublishersTable < SuperClass
  def change
    create_table :publishers do |t|
      t.column :name, :string, { null: false }
      t.belongs_to :address, { foreign_key: true }
      t.timestamps
    end
  end
end

class CreateBooksTable < SuperClass
  def change
    create_table :books do |t|
      t.column :title, :string, { null: false }
      t.belongs_to :author, { foreign_key: true }
      t.belongs_to :publisher, { foreign_key: true }
      t.column :published_date, :date, { null: false }
      t.timestamps
    end
  end
end

class CreateAddressesTable < SuperClass
  def change
    create_table :addresses do |t|
      t.column :street_address_1, :string, { null: false }
      t.column :street_address_2, :string, { null: false, default: '' }
      t.column :city, :string, { null: false }
      t.column :state, :string, { null: false }
      t.column :country, :string, { null: false }
      t.column :postal_code, :string, { null: false }
      t.timestamps
    end
  end
end
