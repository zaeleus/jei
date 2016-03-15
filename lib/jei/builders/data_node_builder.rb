module Jei
  module Builder
    module DataNodeBuilder
      # @param [Serializer] serializer
      # @return [DataNode]
      def self.build(serializer)
        node = DataNode.new
        node.children << ResourceNodeBuilder.build(serializer)
        node
      end
    end
  end
end
