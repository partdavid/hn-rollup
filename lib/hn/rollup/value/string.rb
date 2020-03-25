require 'hn/rollup'

module Hn
  module Rollup

    class Value

      class String < Value

        def self.label
          'string'
        end

        def validate_value(value)
          value.is_a?(::String)
        end

        def aggregate_sibling(sibling)
          self
        end

      end

    end

  end

end
