module Jei
  class Serializer
    # @return [#id]
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

    # @return [Array<String>]
    def key
      [type, id]
    end

    # @return [Boolean]
    def ==(other)
      key == other.key
    end
    alias_method :eql?, :==

    # @return [Fixnum]
    def hash
      key.hash
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
