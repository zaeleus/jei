module Jei
  module Builder
    module DocumentBuilder
      # @param [Object] resource
      # @param [Hash<Symbol, Object>] options
      # @return [Document]
      def self.build(resource, options = {})
        document = Document.new
        root = document.root

        root.children << JSONAPINode.new if options[:jsonapi]
        root.children << MetaNode.new(options[:meta]) if options[:meta]
        root.children << LinksNodeBuilder.build(options[:links]) if options[:links]

        if resource.nil?
          root.children << DataNode.new
          return document
        end

        if resource.is_a?(Enumerable)
          node = CollectionDataNode.new

          if options[:include]
            paths = Path.parse(options[:include])
            included_resources = Set.new

            resource.each do |r|
              Path.find(paths, r, included_resources)

              serializer =
                if options[:serializer]
                  options[:serializer].new(r)
                else
                  Serializer.factory(r)
                end

              node.children << ResourceNodeBuilder.build(serializer)
            end

            root.children << IncludedNodeBuilder.build(included_resources)
          else
            resource.each do |r|
              serializer =
                if options[:serializer]
                  options[:serializer].new(r)
                else
                  Serializer.factory(r)
                end

              node.children << ResourceNodeBuilder.build(serializer)
            end
          end

          root.children << node
        else
          serializer =
            if options[:serializer]
              options[:serializer].new(resource)
            else
              Serializer.factory(resource)
            end

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
