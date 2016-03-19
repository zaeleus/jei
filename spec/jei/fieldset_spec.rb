require 'spec_helper'

module Jei
  describe Fieldset do
    describe '.parse' do
      it 'normalizes fieldset names' do
        fields = {
          'artists' => 'name,albums',
          'albums' => 'released_on'
        }

        fieldsets = Fieldset.parse(fields)

        expected = {
          'artists' => [:name, :albums],
          'albums' => [:released_on]
        }

        expect(fieldsets).to eq(expected)
      end
    end
  end
end
