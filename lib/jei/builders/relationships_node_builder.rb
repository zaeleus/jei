module Jei
  module Builder
    module RelationshipsNodeBuilder
      # @return [RelationshipsNode]
      def self.build(serializer)
        node = RelationshipsNode.new

        serializer.relationships.values.each do |relationship|
          node.children << RelationshipNodeBuilder.build(relationship, serializer)
        end

        node
      end
    end
  end
end
