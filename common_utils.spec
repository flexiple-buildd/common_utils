Gem::Specification.new do |spec|
  spec.name          = 'common_utils'
  spec.version       = '0.1.0'
  spec.summary       = 'Utility functions for common tasks.'
  spec.description   = 'A collection of utility functions including TOCExtractor.'
  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
  spec.add_dependency 'nokogiri', '~> 1.12'
end
