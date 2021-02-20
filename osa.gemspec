# frozen_string_literal: true
require_relative 'lib/osa/version'

Gem::Specification.new do |spec|
  spec.name          = 'osa'
  spec.version       = OSA::VERSION
  spec.authors       = ['Moray Baruh']
  spec.email         = ['contact@moraybaruh.com']

  spec.summary       = 'Outlook Spam Automator'
  spec.description   = 'Get rid of spam on your Outlook account'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 6.0'
  spec.add_dependency 'faraday', '~> 1.1'
  spec.add_dependency 'public_suffix', '~> 4.0'
  spec.add_dependency 'sqlite3', '~> 1.4'
  spec.add_dependency 'tty-prompt', '~> 0.22'
  spec.add_dependency 'sinatra', '~> 2.1.0'
  spec.add_dependency 'sinatra-contrib', '~> 2.1.0'
  spec.add_dependency 'mail', '~> 2.7.1'
end
