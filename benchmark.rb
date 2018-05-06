# frozen_string_literal: true

# To run the benchmark, call:
# ruby benchmark.rb [PATH_TO_FACEBOOK_DIRECTORY]

# If PATH_TO_FACEBOOK_DIRECTORY is omitted, the minimal archive at `./example/facebook-monaleigh` will be used instead

require 'benchmark'

ARGV[0] ||= File.join(File.dirname(__FILE__), 'example/facebook-monaleigh')

Benchmark.bm do |x|
  x.report do
    require_relative File.join(File.dirname(__FILE__), 'lib/facebook_data_analyzer')
    FacebookDataAnalyzer.run
  end
end
