module Jei
  # http://jsonapi.org/format/1.0/#document-resource-objects
  class ResourceNode < Node
    # @param [Hash<Symbol, Object>] context
    def visit(context)
      children.each { |child| child.visit(context) }
    end
  end
end
