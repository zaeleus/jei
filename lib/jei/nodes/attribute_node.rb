module Jei
  module Nodes
    # @see http://jsonapi.org/format/1.0/#document-resource-object-attributes
    class AttributeNode < Node
      # @param [Serializer] serializer
      # @param [Attribute] attribute
      def initialize(serializer, attribute)
        super()
        @serializer = serializer
        @attribute = attribute
      end

      # @param [Hash<Symbol, Object>] context
      def visit(context)
        context[@attribute.name] = @attribute.evaluate(@serializer)
      end
    end
  end
end
