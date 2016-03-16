module Jei
  module Nodes
    # @see http://jsonapi.org/format/1.0/#document-top-level
    class DocumentNode < Node
      # @param [Hash<Symbol, Object>] context
      def visit(context)
        children.each { |child| child.visit(context) }
      end
    end
  end
end
