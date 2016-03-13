module Jei
  class Document
    # @return [String]
    VERSION = '1.0'

    # @return [DocumentNode]
    attr_reader :root

    # @param [Hash<Symbol, Object>] options
    # @option options [Boolean] :jsonapi Add the top level JSON API object to
    #   the document.
    # @option options [Array<Link>] :links Add links related to the primary
    #   data.
    # @option options [Hash<Symbol, Object>] :meta Add top level meta
    #   information to the document.
    def initialize(options = {})
      @options = options

      @root = DocumentNode.new

      add_json_api if options[:jsonapi]
      add_meta(options[:meta]) if options[:meta]
      add_links(options[:links]) if options[:links]
    end

    # Adds a JSON API node to the document.
    def add_json_api
      root.children << JSONAPINode.new
    end

    # Adds non-standard meta information to the document.
    #
    # @param [Hash<Symbol, Object>] meta
    def add_meta(meta)
      root.children << MetaNode.new(meta)
    end

    # Adds links to related to the primary data to the document.
    #
    # @param [Array<Link>] links
    def add_links(links)
      links_node = LinksNode.new

      links.each do |link|
        link_node = LinkNode.new(link)
        links_node.children << link_node
      end

      root.children << links_node
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
