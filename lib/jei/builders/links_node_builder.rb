module Jei
  module Builder
    module LinksNodeBuilder
      include Nodes

      # @param [Array<Link>] links
      # @return [LinksNode]
      def self.build(links)
        links_node = LinksNode.new

        links.each do |link|
          links_node.children << LinkNode.new(link)
        end

        links_node
      end
    end
  end
end
