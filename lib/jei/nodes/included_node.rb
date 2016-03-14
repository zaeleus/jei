module Jei
  # @see http://jsonapi.org/format/1.0/#document-compound-documents
  class IncludedNode < Node
    def visit(context)
      context[:included] = children.map do |child|
        data = {}
        child.visit(data)
        data
      end
    end
  end
end
