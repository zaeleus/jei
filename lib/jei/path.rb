module Jei
  class Path
    class NameError < Jei::Error; end

    PATH_SEPARATOR = ','.freeze
    NAME_SEPARATOR = '.'.freeze

    # @return [Array<Symbol>]
    attr_reader :names

    # @param [String] paths
    # @return [Array<Path>]
    def self.parse(paths)
      paths.split(PATH_SEPARATOR).map do |path|
        new(path.split(NAME_SEPARATOR).map(&:to_sym))
      end
    end

    # @param [Array<Path>] paths
    # @param [Serializer] serializer
    # @param [Set<Serializer>] serializers
    def self.find(paths, serializer, serializers)
      paths.each do |path|
        path.walk(serializer, serializers)
      end
    end

    # @param [Array<Symbol>] names
    def initialize(names)
      @names = names
    end

    # @param [Serializer] serializer
    # @param [Set<Serializer>] serializers
    # @param [Integer] level
    def walk(serializer, serializers, level = 0)
      return if level >= @names.length

      name = @names[level]

      relationship = serializer.relationships[name]
      raise NameError, "invalid relationship name `#{name}'" unless relationship

      unless relationship.options[:data]
        serializer.options[:linkages] = Set.new unless serializer.options[:linkages]
        serializer.options[:linkages] << name
      end

      resources = [*relationship.evaluate(serializer)]

      resources.each do |resource|
        serializer = Serializer.factory(resource, relationship.options[:serializer])
        serializers << serializer
        walk(serializer, serializers, level + 1)
      end
    end
  end
end
