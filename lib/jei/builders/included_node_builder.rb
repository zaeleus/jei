module Jei
  module Builders
    module IncludedNodeBuilder
      include Nodes

      # @param [Set<Serializer>] serializers
      # @return [IncludedNode]
      def self.build(serializers)
        node = IncludedNode.new

        serializers.each do |serializer|
          node.children << ResourceNodeBuilder.build(serializer)
        end

        node
      end
    end
  end
end
