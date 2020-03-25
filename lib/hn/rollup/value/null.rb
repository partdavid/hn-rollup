require 'hn/rollup'

module Hn
  module Rollup

    class Value

      class Null < Value

        def self.label
          'null'
        end

        def validate_value(value)
          value.nil?
        end

      end

    end

  end
end
