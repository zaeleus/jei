require 'spec_helper'

module Jei
  module Nodes
    describe AttributeNode do
      describe '#visit' do
        it 'sets the attribute name to the attribute value' do
          artist = Artist.new(kind: :person, name: 'FIESTAR')
          serializer = ArtistSerializer.new(artist)
          attribute = serializer.attributes[:name]

          node = AttributeNode.new(serializer, attribute)

          context = {}
          node.visit(context)

          expect(context).to eq({ name: 'FIESTAR' })
        end
      end
    end
  end
end
