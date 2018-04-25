# To set up the test, replace in facebook_data_analyzer/analyze_facebook_data.rb the following line:
# Workbook.new(catalog: ARGV[0])
# with:
# Workbook.new(catalog: '/Users/.../facebook_data_analyzer/example/facebook-monaleigh/')
# A complete path needs to be specified instead of /.../ .

# Run the test in Terminal with the following command:
# ruby benchmark.rb

require 'benchmark'

Benchmark.bm do |x|
  x.report { require_relative 'analyze_facebook_data' }
end
