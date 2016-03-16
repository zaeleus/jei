module Jei
  module Builder
    module ResourceNodeBuilder
      include Nodes

      # @param [Serializer] serializer
      # @return [ResourceNode]
      def self.build(serializer)
        node = ResourceNode.new

        node.children << ResourceIdentifierNode.new(serializer)

        if serializer.attributes.any?
          node.children << AttributesNodeBuilder.build(serializer)
        end

        if serializer.relationships.any?
          node.children << RelationshipsNodeBuilder.build(serializer)
        end

        links = serializer.links

        if links
          node.children << LinksNodeBuilder.build(links)
        end

        node
      end
    end
  end
end
