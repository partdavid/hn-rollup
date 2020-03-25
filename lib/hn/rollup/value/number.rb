require 'hn/rollup/value'

module Hn
  module Rollup

    class Value

      class Number < Value

        def self.label
          'number'
        end

        def validate_value(value)
          value.is_a? Numeric
        end

        def aggregate_sibling(sibling)
          self.class.new({ label => canonical_value + sibling.canonical_value })
        end

      end

    end

  end
end
