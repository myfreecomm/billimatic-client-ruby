# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'billimatic/version'

Gem::Specification.new do |spec|
  spec.name          = 'billimatic-client'
  spec.version       = Billimatic::VERSION
  spec.authors       = ['Rodrigo Tassinari de Oliveira', 'Victor Franco']
  spec.email         = ['rodrigo@pittlandia.net', 'victor.alexandrefs@gmail.com']

  spec.summary       = %q{This is the official Ruby client for the Billimatic API.}
  spec.description   = %q{This is the official Ruby client for the Billimatic API. See http://www.billimatic.com.br for more information.}
  spec.homepage      = 'https://github.com/myfreecomm/billimatic-client-ruby/'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'typhoeus', '~> 0.8'
  spec.add_dependency 'multi_json', '~> 1.11'
  spec.add_dependency 'virtus', '~> 1.0.5'
  spec.add_dependency 'wisper', '~> 1.6.1'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 11.1'
  spec.add_development_dependency 'vcr', '~> 3.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.3'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.5'
  spec.add_development_dependency 'simplecov', '~> 0.11'
  spec.add_development_dependency 'guard-rspec', '~> 4.6' unless `ruby --version` =~ /ruby 2\.1+/
  spec.add_development_dependency 'test_notifier', '~> 2.0'
end
