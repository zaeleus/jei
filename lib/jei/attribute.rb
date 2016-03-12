module Jei
  class Attribute
    # @return [Symbol]
    attr_reader :name

    # @param [Symbol] name
    # @param [Proc, Symbol] value
    def initialize(name, value = name)
      @name = name
      @value = value
    end

    # @param [Serializer] serializer
    def evaluate(serializer)
      if @value.is_a?(Proc)
        serializer.instance_eval(&@value)
      else
        serializer.resource.send(@value)
      end
    end
  end
end
