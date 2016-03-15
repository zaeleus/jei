module Jei
  class Serializer
    # @return [#id]
    attr_reader :resource

    # @return [Hash<Symbol, Attribute>]
    def self.serialization_map
      @serialization_map ||= Hash.new { |h, k| h[k] = {} }
    end

    # @overload attributes(name, ...)
    #   @param [Symbol] name
    #   @param [Symbol] ...
    def self.attributes(*names)
      names.each { |name| attribute(name) }
    end

    # @param [Symbol] name
    def self.attribute(name, &blk)
      value = block_given? ? blk : name
      serialization_map[:attributes][name] = Attribute.new(name, value)
    end

    # @param [Symbol] name
    def self.belongs_to(name, options = {}, &blk)
      value = block_given? ? blk : name
      serialization_map[:relationships][name] =
        BelongsToRelationship.new(name, value, options)
    end

    # @param [Symbol] name
    def self.has_many(name, options = {}, &blk)
      value = block_given? ? blk : name
      serialization_map[:relationships][name] =
        HasManyRelationship.new(name, value, options)
    end

    # @return [Serializer]
    def self.factory(resource)
      name = resource.class.name
      klass = const_get("#{name}Serializer")
      klass.new(resource)
    end

    # @param [#id] resource
    def initialize(resource)
      @resource = resource
    end

    # @return [String]
    def id
      resource.id.to_s
    end

    # @return [String]
    def type
      "#{resource.class.name.downcase}s"
    end

    # @return [Hash<Symbol, Attribute>]
    def attributes
      self.class.serialization_map[:attributes]
    end

    # @return [Hash<Symbol, Relationship>]
    def relationships
      self.class.serialization_map[:relationships]
    end

    # @return [Array<Link>, nil]
    def links
      nil
    end

    # @return [Array<String>]
    def key
      [type, id]
    end

    # @return [Fixnum]
    def hash
      key.hash
    end
  end
end
