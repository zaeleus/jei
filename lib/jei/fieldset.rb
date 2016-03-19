module Jei
  class Fieldset
    NAME_SEPARATOR = ','

    def self.parse(raw_fields)
      fields = {}

      raw_fields.each do |type, names|
        fields[type] = names.split(NAME_SEPARATOR).map(&:to_sym)
      end

      fields
    end
  end
end
