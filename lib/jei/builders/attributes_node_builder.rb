module Jei
  module Builder
    module AttributesNodeBuilder
      # @param [Serializer] serializer
      # @return [AttributesNode]
      def self.build(serializer)
        node = AttributesNode.new

        serializer.attributes.values.each do |attribute|
          node.children << AttributeNode.new(serializer, attribute)
        end

        node
      end
    end
  end
end
