module Jei
  class Document
    class Builder
      # @return [Document]
      def self.build(serializer, options = {})
        document = Document.new(options)

        data_node = DataNode.new
        data_node.children << ResourceIdentifierNode.new(serializer)

        attributes = serializer.attributes

        if attributes.any?
          attributes_node = AttributesNode.new

          attributes.values.each do |attribute|
            node = AttributeNode.new(serializer, attribute)
            attributes_node.children << node
          end

          data_node.children << attributes_node
        end

        relationships = serializer.relationships

        if relationships.any?
          relationships_node = RelationshipsNode.new

          relationships.values.each do |relationship|
            node = RelationshipNode.new(relationship)

            if relationship.is_a? HasManyRelationship
              relationship_data_node = CollectionDataNode.new

              resources = relationship.evaluate(serializer)

              resources.each do |resource|
                s = Serializer.factory(resource)
                relationship_data_node.children << ResourceIdentifierNode.new(s)
              end

              node.children << relationship_data_node
            else
              relationship_data_node = DataNode.new
              resource = relationship.evaluate(serializer)
              s = Serializer.factory(resource)
              relationship_data_node.children << ResourceIdentifierNode.new(s)
              node.children << relationship_data_node
            end

            relationships_node.children << node
          end

          data_node.children << relationships_node
        end

        document.root.children << data_node

        document
      end
    end
  end
end
