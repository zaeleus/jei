module Jei
  class Document
    # @return [String]
    VERSION = '1.0'

    # @return [DocumentNode]
    attr_reader :root

    # @param [Object] resource
    # @param [Hash<Symbol, Object>] options
    # @option options [Boolean] :jsonapi Add the top level JSON API object to
    #   the document.
    # @option options [Array<Link>] :links Add links related to the primary
    #   data.
    # @option options [Hash<Symbol, Object>] :meta Add top level meta
    #   information to the document.
    # @return [Document]
    def self.build(resource, options = {})
      Builder::DocumentBuilder.build(resource, options)
    end

    def initialize
      @root = DocumentNode.new
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
