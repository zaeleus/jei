module Jei
  module Builders
    module RelationshipsNodeBuilder
      include Nodes

      # @param [Serializer] serializer
      # @return [RelationshipsNode]
      def self.build(relationships, serializer)
        node = RelationshipsNode.new

        relationships.each do |relationship|
          node.children << RelationshipNodeBuilder.build(relationship, serializer)
        end

        node
      end
    end
  end
end
