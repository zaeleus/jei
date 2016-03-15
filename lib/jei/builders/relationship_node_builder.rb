module Jei
  module Builder
    module RelationshipNodeBuilder
      # @param [Relationship] relationship
      # @param [Serializer] serializer
      # @return [RelationshipNode]
      def self.build(relationship, serializer)
        node = RelationshipNode.new(relationship)

        if relationship.options[:data]
          node.children <<
            case relationship
            when BelongsToRelationship
              build_data_node(relationship, serializer)
            when HasManyRelationship
              build_collection_data_node(relationship, serializer)
            else
              raise ArgumentError, 'invalid relationship type'
            end
        end

        if relationship.options[:links]
          node.children << build_links_node(relationship, serializer)
        end

        node
      end

      # @param [Relationship] relationship
      # @param [Serializer] serializer
      # @return [DataNode]
      def self.build_data_node(relationship, serializer)
        node = DataNode.new
        resource = relationship.evaluate(serializer)

        serializer = Serializer.factory(resource, relationship.options[:serializer])
        node.children << ResourceIdentifierNode.new(serializer)

        node
      end

      # @param [Relationship] relationship
      # @param [Serializer] serializer
      # @return [CollectionDataNode]
      def self.build_collection_data_node(relationship, serializer)
        node = CollectionDataNode.new
        resources = relationship.evaluate(serializer)

        resources.each do |resource|
          serializer = Serializer.factory(resource, relationship.options[:serializer])
          node.children << ResourceIdentifierNode.new(serializer)
        end

        node
      end

      # @param [Relationship] relationship
      # @param [Serializer] serializer
      # @return [LinksNode]
      def self.build_links_node(relationship, serializer)
        links = relationship.links(serializer)
        LinksNodeBuilder.build(links)
      end
    end
  end
end
