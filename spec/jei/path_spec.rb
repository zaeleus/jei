require 'spec_helper'

module Jei
  describe Path do
    describe '.parse' do
      it 'parses a list of relationships' do
        raw_paths = 'a,b.c.d,e.f'
        paths = Path.parse(raw_paths)
        expect(paths[0].names).to eq([:a])
        expect(paths[1].names).to eq([:b, :c, :d])
        expect(paths[2].names).to eq([:e, :f])
      end
    end
  end
end
