module Jei
  module Builders
    module DocumentBuilder
      include Nodes

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

        fieldsets = options[:fields] ? Fieldset.parse(options[:fields]) : {}

        if resource.is_a?(Enumerable)
          node = CollectionDataNode.new

          if options[:include]
            paths = Path.parse(options[:include])
            serializers = Set.new

            resource.each do |r|
              serializer = Serializer.factory(r, options[:serializer])
              Path.find(paths, serializer, serializers)
              fieldset = fieldsets[serializer.type]
              node.children << ResourceNodeBuilder.build(serializer, fieldset)
            end

            root.children << IncludedNodeBuilder.build(serializers, fieldsets)
          else
            resource.each do |r|
              serializer = Serializer.factory(r, options[:serializer])
              fieldset = fieldsets[serializer.type]
              node.children << ResourceNodeBuilder.build(serializer, fieldset)
            end
          end

          root.children << node
        else
          node = DataNode.new

          serializer = Serializer.factory(resource, options[:serializer])
          fieldset = fieldsets[serializer.type]

          node.children << ResourceNodeBuilder.build(serializer, fieldset)

          if options[:include]
            paths = Path.parse(options[:include])
            serializers = Set.new
            Path.find(paths, serializer, serializers)
            root.children << IncludedNodeBuilder.build(serializers, fieldsets)
          end

          root.children << node
        end

        document
      end
    end
  end
end
