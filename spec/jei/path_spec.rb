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

    describe '.walk' do
      before do
        %w[A B C D].each { |c| stub_const(c, Class.new(OpenStruct)) }

        stub_const('ASerializer', Class.new(Serializer) do
          has_many :bs
        end)
        stub_const('BSerializer', Class.new(Serializer) do
          belongs_to :a
          has_many :cs
        end)
        stub_const('CSerializer', Class.new(Serializer) do
          belongs_to :b
          belongs_to :d
        end)
        stub_const('DSerializer', Class.new(Serializer) do
          has_many :cs
        end)
      end

      it 'gathers all unique resources along the path' do
        a1 = A.new(id: 1)

        b1 = B.new(id: 1)
        b2 = B.new(id: 2)

        a1.bs = [b1, b2]

        d1 = D.new(id: 1)
        d2 = D.new(id: 2)

        c1 = C.new(id: 1, d: d1)
        c2 = C.new(id: 2, d: d1)
        c3 = C.new(id: 3, d: d2)
        c4 = C.new(id: 4, d: d2)

        b1.cs = [c1, c2, c3]
        b2.cs = [c2, c3, c4]

        path = Path.new([:bs, :cs, :d])

        serializer = ASerializer.new(a1)
        serializers = Set.new
        path.walk(serializer, serializers)

        resources = [b1, b2, c1, c2, c3, c4, d1, d2]
        expected = resources.reduce(Set.new) do |s, r|
          s << Serializer.factory(r)
          s
        end

        expect(serializers).to eq(expected)
      end
    end
  end
end
