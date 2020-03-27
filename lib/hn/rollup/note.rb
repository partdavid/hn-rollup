require 'hn/rollup'

module Hn

  module Rollup

    class Note < Hash

      def initialize(document)
        if document.is_a? Hn::Rollup::Note
          @document = document.document.dup
          @hn_info = document.hn_info # I guess? still reserved
          @children = document.children
          self.merge!(document)
        else
          @document = document.dup
          @hn_info = @document.delete('hn_info')
          @children = @document.delete('children')
          if @children
            @children = @children.map { |child| Hn::Rollup::Note.new(child) }
          end
          @document.each do |field, value|
            self[field] = Hn::Rollup::Value.make(value)
          end
        end
      end

      def document
        @document
      end

      def hn_info
        @hn_info
      end

      def canonical
        note(value_style: :canonical)
      end

      def reduce
        note(value_style: :reduce)
      end

      def note(value_style: :note)
        me = { }
        self.each do |field, value|
          me[field] = value.value(value_style)
        end

        if children
          me['children'] = children.map { |child| child.send(value_style) }
        end

        if hn_info
          me['hn_info'] = hn_info
        end
        me
      end

      def children
        @children
      end

      def rollup
        aggregate
      end

      def aggregate
        if @children
          aggregated_child = @children.shift
          @children.each { |sibling| aggregated_child.aggregate_sibling(sibling) }
          aggregate_child(aggregated_child)
          @children = nil
        end
        self
      end

      def aggregate_sibling(sibling)
        sibling.aggregate
        sibling.each do |field, sibling_value|
          if has_key?(field)
            self[field] = self[field].aggregate_sibling(sibling_value)
          else
            self[field] = sibling_value
          end
        end
        self
      end

      def aggregate_child(child)
        child.aggregate
        child.each do |field, child_value|
          if has_key?(field)
            old = self[field].canonical
            self[field] = self[field].aggregate_child(child_value)
          else
            self[field] = child_value
          end
        end
        self
      end

    end

  end

end
