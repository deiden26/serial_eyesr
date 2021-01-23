lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'serial_eyesr/version'

Gem::Specification.new do |spec|
  spec.name          = 'serial_eyesr'
  spec.version       = SerialEyesr::VERSION
  spec.authors       = ['Danny Eiden']
  spec.email         = ['deiden26@gmail.com']

  spec.summary       = 'A serializer built to work with Rails and Sorbet'
  spec.description   = 'Serialeyesr is a serializing framework built to put '\
    'typed, performative serialization on rails. Configure the serialized '\
    'fields, types, default page size, related includes, and active record '\
    'with a clear, declarative syntax that makes N+1 queries difficult to produce.'
  spec.homepage      = 'https://github.com/deiden26/serial_eyesr'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/deiden26/serial_eyesr'
  spec.metadata['changelog_uri'] = 'https://github.com/deiden26/serial_eyesr/pulls?q=is%3Apr+is%3Amerged+'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = ['>= 2.4.0']

  spec.add_dependency 'activerecord', '>= 3.1.0', '< 7'
  spec.add_dependency 'sorbet-runtime', '~> 0.5.6155'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'byebug', '~> 11.1.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.92.0'
  spec.add_development_dependency 'sorbet', '~> 0.5.6155'
  spec.add_development_dependency 'sqlite3', '~> 1.4.2'
end
