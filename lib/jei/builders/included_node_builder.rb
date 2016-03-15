module Jei
  module Builder
    module IncludedNodeBuilder
      # @param [Set<Object>] resources
      # @return [IncludedNode]
      def self.build(resources)
        node = IncludedNode.new

        resources.each do |resource|
          serializer = Serializer.factory(resource)
          node.children << ResourceNodeBuilder.build(serializer)
        end

        node
      end
    end
  end
end
