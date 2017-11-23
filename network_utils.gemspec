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

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: Set to \'http://mygemserver.com\''
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',        '~> 1.16'
  spec.add_development_dependency 'byebug',         '~> 9.1'
  spec.add_development_dependency 'inch',           '~> 0.7'
  spec.add_development_dependency 'letters',        '~> 0.4'
  spec.add_development_dependency 'rake',           '~> 12.2'
  spec.add_development_dependency 'rspec',          '~> 3.7'
  spec.add_development_dependency 'rubocop',        '~> 0.51'
  spec.add_development_dependency 'rubygems-tasks', '~> 0.2'
  spec.add_development_dependency 'simplecov',      '~> 0.15'
  spec.add_development_dependency 'vcr',            '~> 3.0'
  spec.add_development_dependency 'webmock',        '~> 3.1'
  spec.add_development_dependency 'yard',           '~> 0.8'

  spec.add_dependency 'activesupport', '~> 5.1'
  spec.add_dependency 'addressable',   '~> 2.5'
  spec.add_dependency 'httparty',      '~> 0.15'
  spec.add_dependency 'url_regex',     '~> 0.0.3'
end
