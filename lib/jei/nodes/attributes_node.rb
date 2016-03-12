module Jei
  # @see http://jsonapi.org/format/1.0/#document-resource-object-attributes
  class AttributesNode < Node
    # @param [Hash<Symbol, Object>] context
    def visit(context)
      attributes = {}
      children.each { |child| child.visit(attributes) }
      context[:attributes] = attributes
    end
  end
end
