require 'hn/rollup'

module Hn
  module Rollup

    class Value

      class << self

        def units
          # TODO: Make dynamic (plugins)
          @units ||= [
            Hn::Rollup::Value::Null,
            Hn::Rollup::Value::Boolean,
            Hn::Rollup::Value::Number,
            Hn::Rollup::Value::String
          ]
          @units
        end

        def labels
          @labels ||= Hash[units.map { |c| [c.label, c] }]
          @labels
        end

        def make(repr)
          if repr.respond_to? :keys
            repr_label = repr.keys.first
            the_class = labels[repr_label]
            if (the_class)
              the_class.new(repr)
            else
              Hn::Rollup::Value.new(repr)
            end
          else
            units.each do |the_class|
              begin
                return the_class.new(repr)
              rescue Hn::Rollup::Error::NotA
                next
              end
              return Hn::Rollup::Value.new(repr)
            end
          end
        end

        def label
          "a supported label (one of: #{labels.keys.join(", ")})"
        end

      end

      def initialize(repr)
        @original = repr
        if repr.respond_to? :keys
          @canonical_value = from_canonical(repr)
        else
          @canonical_value = from_untagged(repr)
        end
        raise(Hn::Rollup::Error::NotA.new("Not a #{self.class}, value #{@canonical_value.inspect} " +
                                    "(#{@canonical_value.class}) is invalid")) unless validate_value(@canonical_value)
      end

      def canonical_value=(new_value)
        @canonical_value = new_value
      end

      def canonical_value
        @canonical_value
      end

      def label
        self.class.label
      end

      def validate_value(repr_value)
        true
      end

      def from_canonical(repr)
        repr_label = repr.keys.first
        raise(Hn::Rollup::Error::NotA.new("Not a #{self.class}, #{repr_label.inspect} != #{label}")) unless
          repr_label == label
        repr[label]
      end

      def from_untagged(repr)
        repr
      end

      def aggregate_sibling(sibling)
        sibling
      end

      def aggregate_child(child)
        aggregate_sibling(child)
      end

      def reduce
        canonical_value
      end

      def canonical
        {
          label => canonical_value
        }
      end

      def value(value_style=:note)
        case value_style
        when :canonical
          canonical
        when :reduce
          reduce
        else
          @original
        end
      end

    end

  end
end

require 'hn/rollup/value/null'
require 'hn/rollup/value/boolean'
require 'hn/rollup/value/number'
require 'hn/rollup/value/string'

