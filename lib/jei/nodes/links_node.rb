module Jei
  module Nodes
    # @see http://jsonapi.org/format/1.0/#document-links
    class LinksNode < Node
      # @param [Hash<Symbol, Object>] context
      def visit(context)
        data = {}
        children.each { |child| child.visit(data) }
        context[:links] = data
      end
    end
  end
end
