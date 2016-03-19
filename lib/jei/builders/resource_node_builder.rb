module Jei
  module Builders
    module ResourceNodeBuilder
      include Nodes

      # @param [Serializer] serializer
      # @param [Array<Symbol>] fieldset
      # @return [ResourceNode]
      def self.build(serializer, fieldset = nil)
        node = ResourceNode.new

        node.children << ResourceIdentifierNode.new(serializer)

        attributes = serializer.attributes(fieldset).values

        if attributes.any?
          node.children << AttributesNodeBuilder.build(attributes, serializer)
        end

        relationships = serializer.relationships(fieldset).values

        if relationships.any?
          node.children << RelationshipsNodeBuilder.build(relationships, serializer)
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
