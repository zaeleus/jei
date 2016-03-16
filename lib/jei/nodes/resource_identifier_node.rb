module Jei
  module Nodes
    # http://jsonapi.org/format/1.0/#document-resource-identifier-objects
    class ResourceIdentifierNode < Node
      # param [Serializer] serializer
      def initialize(serializer)
        super()
        @serializer = serializer
      end

      # @param [Hash<Symbol, Object>] context
      def visit(context)
        context[:id] = @serializer.id
        context[:type] = @serializer.type
      end
    end
  end
end
