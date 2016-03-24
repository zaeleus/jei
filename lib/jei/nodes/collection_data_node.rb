module Jei
  module Nodes
    # @see http://jsonapi.org/format/#document-top-level
    class CollectionDataNode < DataNode
      EMPTY_LIST = [].freeze

      # @param [Hash<Symbol, Object>] context
      def visit(context)
        context[:data] =
          if children.empty?
            EMPTY_LIST
          else
            children.map do |child|
              data = {}
              child.visit(data)
              data
            end
          end
      end
    end
  end
end
