module Jei
  module Builder
    module DocumentBuilder
      # @param [Object] resource
      # @param [Hash<Symbol, Object>] options
      # @return [Document]
      def self.build(resource, options = {})
        document = Document.new(options)
        root = document.root

        if resource.is_a?(Enumerable)
          node = CollectionDataNode.new

          if options[:include]
            paths = Path.parse(options[:include])
            included_resources = Set.new

            resource.each do |r|
              Path.find(paths, r, included_resources)
              serializer = Serializer.factory(r)
              node.children << ResourceNodeBuilder.build(serializer)
            end

            root.children << IncludedNode.build(included_resources)
          else
            resource.each do |r|
              serializer = Serializer.factory(r)
              node.children << ResourceNodeBuilder.build(serializer)
            end
          end

          root.children << node
        else
          serializer = Serializer.factory(resource)

          root.children << DataNodeBuilder.build(serializer)

          if options[:include]
            paths = Path.parse(options[:include])
            included_resources = Set.new
            Path.find(paths, resource, included_resources)
            root.children << IncludedNodeBuilder.build(included_resources)
          end
        end

        document
      end
    end
  end
end
