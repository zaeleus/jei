module Jei
  module Nodes
    # @see http://jsonapi.org/format/1.0/#document-resource-object-relationships
    class RelationshipsNode < Node
      # @param [Hash<Symbol, Object>] context
      def visit(context)
        relationships = {}
        children.each { |child| child.visit(relationships) }
        context[:relationships] = relationships
      end
    end
  end
end
