module Jei
  class Link
    # @return [String]
    attr_reader :name

    # @return [String]
    attr_reader :href

    # @return [Hash<Symbol, Object>]
    attr_reader :meta

    # @param [Symbol] name
    # @param [String] href
    # @param [Hash<Symbol, Object>] meta
    def initialize(name, href, meta = {})
      @name = name
      @href = href
      @meta = meta
    end
  end
end
