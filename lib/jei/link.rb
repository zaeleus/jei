module Jei
  class Link
    attr_reader :name, :href, :meta

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
