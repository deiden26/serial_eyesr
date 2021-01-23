require 'serial_eyesr/version'

module SerialEyesr
  autoload :Serializer, 'serial_eyesr/serializer.rb'

  class Error < StandardError; end
end
