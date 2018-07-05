# frozen_string_literal: true

module FacebookDataAnalyzer
  class Analyzeable
    attr_reader :grouped_by, :counted_by

    def self.parse
      raise 'needs to be implemented by concrete class'
    end

    GROUP_BY = [].freeze
    COUNT_BY = [].freeze

    def initialize(threads_supported: nil, processes_supported: nil, parallel: false)
      # Grouped by is weird and needs a hash for each GROUP_BY, hash for each unique group, and hash for attributes
      @grouped_by = Hash.new do |by_group, key|
        by_group[key] = Hash.new do |group_name, attribute|
          group_name[attribute] = Hash.new(nil)
        end
      end
      @counted_by = Hash.new { |hash, key| hash[key] = Hash.new(0) }

      # Thread/Process limit for Parallel processing
      @threads_supported = parallel && !threads_supported ? 10 : threads_supported || 0
      @processes_supported = parallel && !processes_supported ? 5 : processes_supported || 0
    end

    def analyze
      raise 'needs to be implemented by concrete class'
    end

    def export(package:)
      raise 'needs to be implemented by concrete class'
    end

    private

    def group(analyzeable:, aggregate_hash: @grouped_by)
      self.class::GROUP_BY.each do |attribute|
        grouping_method = "group_by_#{attribute}".to_sym

        next unless analyzeable.respond_to?(grouping_method)
        grouped_analyzeable = analyzeable.send(grouping_method)

        grouped_analyzeable.each do |group, group_attributes|
          group_attributes.each do |group_attribute_key, group_attribute_value|
            current_grouping = aggregate_hash[attribute][group][group_attribute_key]
            if current_grouping.nil?
              aggregate_hash[attribute][group][group_attribute_key] = group_attribute_value
            else
              aggregate_hash[attribute][group][group_attribute_key] += group_attribute_value
            end
          end
        end
      end
    end

    def count(analyzeable:, aggregate_hash: @counted_by)
      self.class::COUNT_BY.each do |attribute|
        counting_method = "count_by_#{attribute}".to_sym

        next unless analyzeable.respond_to?(counting_method)
        countables = analyzeable.send(counting_method)

        countables.each do |countable|
          aggregate_hash[attribute][countable] += 1
        end
      end
    end
  end
end
