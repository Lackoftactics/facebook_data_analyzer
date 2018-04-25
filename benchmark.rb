# To run the benchmark, call:
# ruby benchmark.rb [PATH_TO_FACEBOOK_DIRECTORY]

# If PATH_TO_FACEBOOK_DIRECTORY is omitted, the minimal archive at `./example/facebook-monaleigh` will be used instead

require 'benchmark'

WORKBOOK = File.join(File.dirname(__FILE__), 'example/facebook-monaleigh')
ARGV[0] = ARGV[0] || WORKBOOK

Benchmark.bm do |x|
  x.report { require_relative 'analyze_facebook_data' }
end
