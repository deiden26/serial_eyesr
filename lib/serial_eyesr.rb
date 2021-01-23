require 'serial_eyesr/version'

# The publicly exposed elements of the SerialEyesr gem
module SerialEyesr
  autoload :Serializer, 'serial_eyesr/serializer.rb'

  class Error < StandardError; end
end
