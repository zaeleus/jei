module Jei
  class Relationship < Attribute
    attr_reader :options

    # @param [Symbol] name
    # @param [Proc, Symbol] value
    # @param [Hash<Symbol, Object>] options
    # @option options [Boolean] :no_data Whether to exclude data from the
    #   relationship.
    # @option options [Proc] :links A Proc that evaulates to a list of links.
    def initialize(name, value = name, options = {})
      super(name, value)
      @options = options
    end

    # @param [Serializer] serializer
    # @return [Array<Link>]
    def links(serializer)
      serializer.instance_eval(&options[:links])
    end
  end

  class BelongsToRelationship < Relationship
  end

  class HasManyRelationship < Relationship
  end
end
