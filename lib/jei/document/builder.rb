module Jei
  class Document
    module Builder
      EMPTY_COLLECTION = [].freeze
      EMPTY_FIELDSETS = {}.freeze

      module_function

      # @param [Object] resource
      # @param [Hash<Symbol, Object>] options
      # @return [Document]
      def build(resource, options = {})
        document = Document.new
        root = document.root

        build_json_api(root) if options[:jsonapi]
        build_meta(root, options[:meta]) if options[:meta]
        build_links(root, options[:links]) if options[:links]

        if options[:errors]
          build_errors(root, options[:errors])
        elsif resource.nil?
          root[:data] = nil
        elsif resource.is_a?(Enumerable)
          build_collection(root, resource, options)
        else
          build_single(root, resource, options)
        end

        document
      end

      # @see http://jsonapi.org/format/1.0/#document-jsonapi-object
      # @param [Hash<Symbol, Object>] context
      def build_json_api(context)
        context[:jsonapi] = { version: Document::VERSION }
      end

      # @see http://jsonapi.org/format/1.0/#document-meta
      # @param [Hash<Symbol, Object>] context
      # @param [Hash<Symbol, Object>] meta
      def build_meta(context, meta)
        context[:meta] = meta
      end

      # @see http://jsonapi.org/format/1.0/#document-links
      # @param [Hash<Symbol, Object>] context
      # @param [Array<Link>] links
      def build_links(context, links)
        root = {}
        links.each { |link| build_link(root, link) }
        context[:links] = root
      end

      # @see http://jsonapi.org/format/1.0/#document-links
      # @param [Hash<Symbol, Object>] context
      # @param [Link] link
      def build_link(context, link)
        context[link.name] =
          if link.meta.any?
            { href: link.href, meta: link.meta }
          else
            link.href
          end
      end

      # @see http://jsonapi.org/format/1.0/#document-top-level
      # @param [Hash<Symbol, Object>] context
      # @param [Object] resource
      # @param [Hash<Symbol, Object>] options
      def build_single(context, resource, options)
        fieldsets = options[:fields] ? Fieldset.parse(options[:fields]) : EMPTY_FIELDSETS

        serializer = Serializer.factory(resource, options[:serializer])
        fieldset = fieldsets[serializer.type]

        root = {}
        build_resource(root, serializer, fieldset)
        context[:data] = root

        if options[:include]
          paths = Path.parse(options[:include])
          serializers = Set.new
          Path.find(paths, serializer, serializers)
          build_included(context, serializers, fieldsets)
        end
      end

      # @see http://jsonapi.org/format/1.0/#document-top-level
      # @param [Hash<Symbol, Object>] context
      # @param [Enumerable] resources
      # @param [Hash<Symbol, Object>] options
      def build_collection(context, resources, options)
        if resources.empty?
          context[:data] = EMPTY_COLLECTION
          return
        end

        fieldsets = options[:fields] ? Fieldset.parse(options[:fields]) : EMPTY_FIELDSETS

        if options[:include]
          paths = Path.parse(options[:include])
          serializers = Set.new

          context[:data] = resources.map do |resource|
            serializer = Serializer.factory(resource, options[:serializer])

            Path.find(paths, serializer, serializers)

            root = {}
            fieldset = fieldsets[serializer.type]

            build_resource(root, serializer, fieldset)

            root
          end

          build_included(context, serializers, fieldsets)
        else
          context[:data] = resources.map do |resource|
            root = {}
            serializer = Serializer.factory(resource, options[:serializer])
            fieldset = fieldsets[serializer.type]

            build_resource(root, serializer, fieldset)

            root
          end
        end
      end

      # @see http://jsonapi.org/format/1.0/#document-resource-identifier-objects
      # @param [Hash<Symbol, Object>] context
      # @param [Serializer] serializer
      def build_resource_identifier(context, serializer)
        context[:id] = serializer.id
        context[:type] = serializer.type
      end

      # @see http://jsonapi.org/format/1.0/#document-resource-objects
      # @param [Hash<Symbol, Object>] context
      # @param [Serializer] serializer
      # @param [Array<Symbol>, nil] fieldset
      def build_resource(context, serializer, fieldset)
        build_resource_identifier(context, serializer)

        attributes = serializer.attributes(fieldset).values

        if attributes.any?
          build_attributes(context, attributes, serializer)
        end

        relationships = serializer.relationships(fieldset).values

        if relationships.any?
          build_relationships(context, relationships, serializer)
        end

        links = serializer.links

        if links
          build_links(context, links)
        end
      end

      # @see http://jsonapi.org/format/1.0/#document-resource-object-attributes
      # @param [Hash<Symbol, Object>] context
      # @param [Array<Attribute>] attributes
      # @param [Serializer] serializer
      def build_attributes(context, attributes, serializer)
        root = {}

        attributes.each do |attribute|
          root[attribute.name] = attribute.evaluate(serializer)
        end

        context[:attributes] = root
      end

      # @see http://jsonapi.org/format/1.0/#document-resource-object-relationships
      # @param [Hash<Symbol, Object>] context
      # @param [Array<Relationship>] relationships
      # @param [Serializer] serializer
      def build_relationships(context, relationships, serializer)
        root = {}

        relationships.each do |relationship|
          build_relationship(root, relationship, serializer)
        end

        context[:relationships] = root
      end

      # @see http://jsonapi.org/format/1.0/#document-resource-object-relationships
      # @see http://jsonapi.org/format/1.0/#document-resource-object-linkage
      # @param [Hash<Symbol, Object>] context
      # @param [Relationship] relationship
      # @param [Serializer] serializer
      def build_relationship(context, relationship, serializer)
        root = {}

        if relationship.options[:data]
          case relationship
          when BelongsToRelationship
            build_belongs_to_relationship(root, relationship, serializer)
          when HasManyRelationship
            build_has_many_relationship(root, relationship, serializer)
          else
            raise ArgumentError, 'invalid relationship type'
          end
        end

        if relationship.options[:links]
          links = relationship.links(serializer)
          build_links(root, links)
        end

        context[relationship.name] = root
      end

      # @see http://jsonapi.org/format/1.0/#document-resource-object-linkage
      # @param [Hash<Symbol, Object>] context
      # @param [Relationship] relationship
      # @param [Serializer] serializer
      def build_belongs_to_relationship(context, relationship, serializer)
        root = {}
        resource = relationship.evaluate(serializer)
        serializer = Serializer.factory(resource, relationship.options[:serializer])
        build_resource_identifier(root, serializer)
        context[:data] = root
      end

      # @see http://jsonapi.org/format/1.0/#document-resource-object-linkage
      # @param [Hash<Symbol, Object>] context
      # @param [Relationship] relationship
      # @param [Serializer] serializer
      def build_has_many_relationship(context, relationship, serializer)
        resources = relationship.evaluate(serializer)

        context[:data] =
          if resources.empty?
            EMPTY_COLLECTION
          else
            resources.map do |resource|
              root = {}
              serializer = Serializer.factory(resource, relationship.options[:serializer])
              build_resource_identifier(root, serializer)
              root
            end
        end
      end

      # @see http://jsonapi.org/format/1.0/#document-compound-documents
      # @param [Hash<Symbol, Object>] context
      # @param [Set<Serializer>] serializers
      # @param [Hash<String, Array<Symbol>>] fieldsets
      def build_included(context, serializers, fieldsets)
        context[:included] = serializers.map do |serializer|
          root = {}
          fieldset = fieldsets[serializer.type]
          build_resource(root, serializer, fieldset)
          root
        end
      end

      # @see http://jsonapi.org/format/1.0/#error-objects
      # @param [Hash<Symbol, Object>] context
      # @param [Array<Hash<Symbol, Object>>] errors
      def build_errors(context, errors)
        context[:errors] = errors
      end
    end
  end
end
