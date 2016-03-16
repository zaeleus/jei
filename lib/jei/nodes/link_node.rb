module Jei
  module Nodes
    # @see http://jsonapi.org/format/1.0/#document-links
    class LinkNode < Node
      # @param [Link] link
      def initialize(link)
        super()
        @link = link
      end

      # @param [Hash<Symbol, Object>] context
      def visit(context)
        context[@link.name] =
          if @link.meta.any?
            { href: @link.href, meta: @link.meta }
          else
            @link.href
          end
      end
    end
  end
end
