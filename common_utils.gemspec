Gem::Specification.new do |spec|
  spec.name          = 'common_utils'
  spec.version       = '0.1.2'
  spec.summary       = 'Utility functions for common tasks.'
  spec.authors       = ['Aarav']
  spec.description   = 'A collection of utility functions including TOCExtractor.'
  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']
  spec.add_dependency 'nokogiri', '~> 1.16'
end
