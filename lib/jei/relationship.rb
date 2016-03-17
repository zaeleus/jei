module Jei
  class Relationship < Field
    # @return [Hash<Symbol, Object>] options
    attr_reader :options

    # @param [Symbol] name
    # @param [Proc, Symbol] value
    # @param [Hash<Symbol, Object>] options
    # @option options [Boolean] :data (true) whether to include data in the
    #   relationship
    # @option options [Proc] :links a `Proc` that evaulates to a list of links
    # @option options [Class] :serializer override the default serializer used
    #   for related resources
    def initialize(name, value = name, options = {})
      super(name, value)
      options[:data] = options.fetch(:data, true)
      @options = options
    end

    # @param [Serializer] serializer
    # @return [Array<Link>]
    def links(serializer)
      serializer.instance_exec(&options[:links])
    end
  end

  class BelongsToRelationship < Relationship
  end

  class HasManyRelationship < Relationship
  end
end
