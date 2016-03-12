module Jei
  class DataNode < Node
    # @param [Hash<Symbol, Object>] context
    def visit(context)
      context[:data] =
        if children.empty?
          nil
        else
          data = {}
          children.each { |child| child.visit(data) }
          data
        end
    end
  end
end
