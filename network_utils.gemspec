# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'network_utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'network_utils'
  spec.version       = NetworkUtils::VERSION
  spec.authors       = ['smileart']
  spec.email         = ['smileart21@gmail.com']

  spec.summary       = 'A set of convenient network utils'
  spec.description   = 'A set of utils to get URL info before downloading a resource, work with ports, etc.'
  spec.homepage      = 'http://github.com/smileart/network_utils'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'amazing_print',  '~> 1.2'
  spec.add_development_dependency 'bundler',        '~> 2.1'
  spec.add_development_dependency 'byebug',         '~> 11.1'
  spec.add_development_dependency 'inch',           '~> 0.8'
  spec.add_development_dependency 'tapp',           '~> 1.5'
  spec.add_development_dependency 'rake',           '~> 13.0'
  spec.add_development_dependency 'rspec',          '~> 3.9'
  spec.add_development_dependency 'rubocop',        '~> 0.91'
  spec.add_development_dependency 'rubygems-tasks', '~> 0.2'
  spec.add_development_dependency 'simplecov',      '~> 0.19'
  spec.add_development_dependency 'vcr',            '~> 6.0'
  spec.add_development_dependency 'webmock',        '~> 3.9'
  spec.add_development_dependency 'yard',           '~> 0.9'

  spec.add_dependency 'activesupport', '~> 6.0'
  spec.add_dependency 'addressable',   '~> 2.7'
  spec.add_dependency 'httparty',      '~> 0.18'
  spec.add_dependency 'url_regex',     '~> 0.0.3'
end
