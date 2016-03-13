module Jei
  class Path
    PATH_SEPARATOR = ','
    NAME_SEPARATOR = '.'

    attr_reader :names

    # @param [String] paths
    # @return [Array<Path>]
    def self.parse(paths)
      paths.split(PATH_SEPARATOR).map do |path|
        new(path.split(NAME_SEPARATOR).map(&:to_sym))
      end
    end

    # @param [Array<Symbol>] names
    def initialize(names)
      @names = names
    end

    # @param [Object] root
    # @param [Set<Object>] set
    # @param [Integer] level
    def traverse(root, set = Set.new, level = 0)
      return if level >= @names.length

      serializer = Serializer.factory(root)

      name = @names[level]
      relationship = serializer.relationships[name]
      resources = [*relationship.evaluate(serializer)]

      set.merge(resources)

      resources.each do |resource|
        traverse(resource, set, level + 1)
      end
    end
  end
end
