require 'hn/rollup'

module Hn

  module Rollup

    class Note

      def initialize(document)
        @original = document
      end

      def rollup(keep_children: true)
        @original
      end

    end

  end

end
