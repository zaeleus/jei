module Jei
  class DataNode < Node
    # @param [Hash<Symbol, Object>] context
    def visit(context)
      data = {}
      children.each { |child| child.visit(data) }
      context[:data] = data
    end
  end
end
