require 'env/migrations'
require 'env/models'

class SerialEyesr::Env
  class << self
    def db_dir
      @db_dir ||= File.join(File.dirname(File.dirname(__FILE__)), 'tmp')
    end

    def db_file
      @db_file ||= File.join(db_dir, 'test.sqlite3')
    end

    def establish_connection
      ActiveRecord::Base.establish_connection(
        adapter: 'sqlite3',
        database: db_file,
      )
    end

    def migrate
      CreateAuthorsTable.new.change
      CreatePublishersTable.new.change
      CreateBooksTable.new.change
      CreateAddressesTable.new.change
    end

    def reset
      File.unlink(db_file) if File.exist?(db_file)
      FileUtils.mkdir_p(db_dir)
    end
  end
end
