# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'declined'
  spec.version       = '1.0.0'
  spec.authors       = ['Declined.io']
  spec.email         = ['support@declined.io']
  spec.summary       = 'Official Declined.io REST API client for Ruby'
  spec.description   = 'Ruby client for the Declined.io recovery API'
  spec.homepage      = 'https://github.com/Enoros/declined-sdk/tree/main/declined-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.files = Dir['lib/**/*', 'README.md', 'LICENSE']
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 2.9'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'webmock', '~> 3.23'
end
