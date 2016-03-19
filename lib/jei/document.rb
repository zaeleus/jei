module Jei
  class Document
    # @return [String]
    VERSION = '1.0'

    # @return [DocumentNode]
    attr_reader :root

    # Builds a document from a resource.
    #
    # @param [Object] resource
    # @param [Hash<Symbol, Object>] options
    # @option options [Hash<String, String>] :fields restrict resource
    #   attributes and relationships to a user-defined set of fields
    # @option options [String] :include a list of relationship paths
    # @option options [Boolean] :jsonapi add the top level JSON API object to
    #   the document
    # @option options [Array<Link>] :links add links related to the primary
    #   data
    # @option options [Hash<Symbol, Object>] :meta add top level meta
    #   information to the document
    # @option options [Class] :serializer override the default serializer
    # @return [Document]
    def self.build(resource, options = {})
      Builders::DocumentBuilder.build(resource, options)
    end

    def initialize
      @root = Nodes::DocumentNode.new
    end

    # @return [Hash<Symbol, Object>]
    def to_h
      document = {}
      root.visit(document)
      document
    end

    # @return [String]
    def to_json
      to_h.to_json
    end
  end
end
