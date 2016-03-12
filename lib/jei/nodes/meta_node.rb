module Jei
  # @see http://jsonapi.org/format/1.0/#document-meta
  class MetaNode < Node
    # param [Hash<Symbol, Object>] meta
    def initialize(meta)
      super()
      @meta = meta
    end

    # @param [Hash<Symbol, Object>] context
    def visit(context)
      context[:meta] = @meta
    end
  end
end
