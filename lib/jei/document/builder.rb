module Jei
  class Document
    class Builder
      # @return [Document]
      def self.build(resource, options = {})
        document = Document.new(options)

        document.root.children << data_node(resource)

        if options[:include]
          document.root.children << included_node(resource, options[:include])
        end

        document
      end

      def self.data_node(resource)
        data_node = DataNode.new
        data_node.children << resource_node(resource)
        data_node
      end

      def self.resource_node(resource)
        serializer = Serializer.factory(resource)

        resource_node = ResourceNode.new

        resource_node.children << ResourceIdentifierNode.new(serializer)

        attributes = serializer.attributes

        if attributes.any?
          attributes_node = AttributesNode.new

          attributes.values.each do |attribute|
            node = AttributeNode.new(serializer, attribute)
            attributes_node.children << node
          end

          resource_node.children << attributes_node
        end

        relationships = serializer.relationships

        if relationships.any?
          relationships_node = RelationshipsNode.new

          relationships.values.each do |relationship|
            node = RelationshipNode.new(relationship)

            if relationship.options[:links]
              links_node = LinksNode.new
              links = relationship.links(serializer)

              links.each do |link|
                link_node = LinkNode.new(link)
                links_node.children << link_node
              end

              node.children << links_node
            end

            if relationship.is_a? HasManyRelationship
              relationship_data_node = CollectionDataNode.new

              resources = relationship.evaluate(serializer)

              resources.each do |r|
                s = Serializer.factory(r)
                relationship_data_node.children << ResourceIdentifierNode.new(s)
              end

              node.children << relationship_data_node
            else
              relationship_data_node = DataNode.new
              r = relationship.evaluate(serializer)
              s = Serializer.factory(r)
              relationship_data_node.children << ResourceIdentifierNode.new(s)
              node.children << relationship_data_node
            end

            relationships_node.children << node
          end

          resource_node.children << relationships_node
        end

        resource_node
      end

      def self.included_node(resource, include_paths)
        paths = Path.parse(include_paths)

        resources = Set.new

        paths.each do |path|
          path.traverse(resource, resources)
        end

        included_node = IncludedNode.new

        resources.each do |r|
          included_node.children << resource_node(r)
        end

        included_node
      end
    end
  end
end
