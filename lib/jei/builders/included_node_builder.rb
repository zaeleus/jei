module Jei
  module Builders
    module IncludedNodeBuilder
      include Nodes

      # @param [Set<Serializer>] serializers
      # @param [Hash<String, String>] fieldset
      # @return [IncludedNode]
      def self.build(serializers, fieldsets = {})
        node = IncludedNode.new

        serializers.each do |serializer|
          fieldset = fieldsets[serializer.type]
          node.children << ResourceNodeBuilder.build(serializer, fieldset)
        end

        node
      end
    end
  end
end
