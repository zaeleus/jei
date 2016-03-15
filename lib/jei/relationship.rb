module Jei
  class Relationship < Attribute
    # @return [Hash<Symbol, Object>] options
    attr_reader :options

    # @param [Symbol] name
    # @param [Proc, Symbol] value
    # @param [Hash<Symbol, Object>] options
    # @option options [Boolean] :data Whether to include data in the
    #   relationship [default: true].
    # @option options [Proc] :links A Proc that evaulates to a list of links.
    # @option options [Class] :serializer Override the default serializer used
    #   for related resources.
    def initialize(name, value = name, options = {})
      super(name, value)
      options[:data] = options.fetch(:data, true)
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
