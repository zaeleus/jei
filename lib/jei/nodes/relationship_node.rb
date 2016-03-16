module Jei
  module Nodes
    # @see http://jsonapi.org/format/1.0/#document-resource-object-relationships
    class RelationshipNode < Node
      # @param [Relationship] relationship
      def initialize(relationship)
        super()
        @relationship = relationship
      end

      # @param [Hash<Symbol, Object>] context
      def visit(context)
        data = {}
        children.each { |child| child.visit(data) }
        context[@relationship.name] = data
      end
    end
  end
end
