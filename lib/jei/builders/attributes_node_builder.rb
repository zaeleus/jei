module Jei
  module Builders
    module AttributesNodeBuilder
      include Nodes

      # @param [Serializer] serializer
      # @return [AttributesNode]
      def self.build(attributes, serializer)
        node = AttributesNode.new

        attributes.each do |attribute|
          node.children << AttributeNode.new(serializer, attribute)
        end

        node
      end
    end
  end
end
