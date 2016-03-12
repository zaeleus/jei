module Jei
  class CollectionDataNode < DataNode
    # @param [Hash<Symbol, Object>] context
    def visit(context)
      context[:data] = children.map do |child|
        data = {}
        child.visit(data)
        data
      end
    end
  end
end
