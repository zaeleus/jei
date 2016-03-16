module Jei
  module Nodes
    # @see http://jsonapi.org/format/1.0/#document-jsonapi-object
    class JSONAPINode < Node
      # @param [Hash<Symbol, Object>] context
      def visit(context)
        context[:jsonapi] = { version: Document::VERSION }
      end
    end
  end
end
