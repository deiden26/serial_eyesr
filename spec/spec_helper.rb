require 'bundler/setup'
require 'byebug'
require 'env'

require 'serial_eyesr'

def silence
  original_stdout = $stdout
  $stdout = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Set up sample database before each test suite
  config.before(:each) do
    SerialEyesr::Env.establish_connection
    SerialEyesr::Env.reset
    silence { SerialEyesr::Env.migrate }
  end
end
