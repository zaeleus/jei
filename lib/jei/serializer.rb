module Jei
  class Serializer
    # @return [Object]
    attr_reader :resource

    # @return [Hash<Symbol, Attribute>]
    def self.fields
      @fields ||= Hash.new { |h, k| h[k] = {} }
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
      fields[:attributes][name] = Attribute.new(name, value)
    end

    # @param [Symbol] name
    # @param [Hash<Symbol, Object>] options
    # @see Relationship#initialize
    def self.belongs_to(name, options = {}, &blk)
      value = block_given? ? blk : name
      fields[:relationships][name] =
        BelongsToRelationship.new(name, value, options)
    end

    # @param [Symbol] name
    # @param [Hash<Symbol, Object>] options
    # @see Relationship#initialize
    def self.has_many(name, options = {}, &blk)
      value = block_given? ? blk : name
      fields[:relationships][name] =
        HasManyRelationship.new(name, value, options)
    end

    # Instantiates a new serializer based on the type of the given resource.
    #
    # This assumes serializer classes are defined in the global namespace. If
    # not, a serializer class can be passed to override the lookup.
    #
    # @example
    #   artist = Artist.new
    #
    #   serializer = Serializer.factory(artist)
    #   # => #<ArtistSerializer>
    #
    #   serializer = Serializer.factory(artist, SimpleArtistSerializer)
    #   # => #<SimpleArtistSerializer>
    #
    # @param [Object] resource
    # @param [Class] klass the class used instead of serializer lookup
    # @return [Serializer]
    def self.factory(resource, klass = nil)
      klass ||= const_get("#{resource.class.name}Serializer")
      klass.new(resource)
    end

    # @param [#id] resource
    # @param [Hash<Symbol, Object>] options
    def initialize(resource, options = nil)
      @resource = resource
      @options = options
    end

    # @return [String]
    def id
      resource.id.to_s
    end

    # @return [String]
    def type
      "#{resource.class.name.downcase}s"
    end

    # @param [Array<Symbol>] fieldset
    # @return [Hash<Symbol, Attribute>]
    def attributes(fieldset = nil)
      fields(:attributes, fieldset)
    end

    # @param [Array<Symbol>] fieldset
    # @return [Hash<Symbol, Relationship>]
    def relationships(fieldset = nil)
      fields(:relationships, fieldset)
    end

    # @return [Array<Link>, nil]
    def links
      nil
    end

    # @return [Hash<Symbol, Object>]
    def options
      @options ||= {}
    end

    # @return [Array<String>]
    def key
      [type, id]
    end

    # @return [Boolean]
    def ==(other)
      hash == other.hash
    end
    alias_method :eql?, :==

    # Returns a digest for this serializer.
    #
    # The second element is shifted to preserve order.
    #
    # @return [Fixnum]
    def hash
      type.hash ^ (id.hash >> 1)
    end

    private

    # @param [Symbol] type
    # @param [Array<Symbol>] fieldset
    # @return [Hash<Symbol, Field>]
    def fields(type, fieldset = nil)
      fields = self.class.fields[type]

      if fieldset
        slice = {}

        fieldset.each do |name|
          slice[name] = fields[name] if fields.has_key?(name)
        end

        slice
      else
        fields
      end
    end
  end
end
