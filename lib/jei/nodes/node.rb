module Jei
  # @abstract
  class Node
    # @return [Array<Node>]
    attr_reader :children

    def initialize
      @children = []
    end

    # @abstract
    # @param [Hash<Symbol, Object>] _context
    def visit(_context)
      raise NotImplementedError
    end
  end
end
