module Jei
  module Builder
    module IncludedNodeBuilder
      # @param [Set<Serializer>] resources
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
