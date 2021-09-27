# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'facebook_data_analyzer/version'

Gem::Specification.new do |spec|
  spec.name          = 'facebook_data_analyzer'
  spec.version       = FacebookDataAnalyzer::VERSION
  spec.description   = '...'
  spec.summary       = '...'
  spec.authors       = '...'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.add_dependency 'axlsx', '3.0.0.pre' # excel export
  spec.add_dependency 'json' # used for caching
  spec.add_dependency 'micro-optparse' # cli argument parser
  spec.add_dependency 'nokogiri', '>= 1.8.2', '< 1.13.0' # parser
  spec.add_dependency 'parallel' # processing
  spec.add_dependency 'ruby-progressbar'
  spec.add_dependency 'workbook'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'dotenv', '~> 2.4'

  spec.files         = Dir['./**/*'].reject { |file| file =~ /\.\/(bin|log|pkg|script|spec|test|vendor)/ }
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
