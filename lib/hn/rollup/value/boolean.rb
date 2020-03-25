require 'hn/rollup'

module Hn
  module Rollup

    class Value

      class Boolean < Value

        def self.label
          'boolean'
        end

        def validate_value(value)
          value.is_a? TrueClass or value.is_a? FalseClass
        end

        def aggregate_sibling(sibling)
          Hn::Rollup::Value::Null.new(nil)
        end

      end

    end

  end
end
