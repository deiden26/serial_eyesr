require 'active_record'

class Author < ActiveRecord::Base
  has_many :books
  belongs_to :address
end

class Publisher < ActiveRecord::Base
  has_many :books
  belongs_to :address
end

class Book < ActiveRecord::Base
  belongs_to :author
  belongs_to :publisher
end

class Address < ActiveRecord::Base
  has_many :authors
  has_many :publishers
end
