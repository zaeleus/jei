require 'spec_helper'

module Jei
  module Nodes
    describe ResourceIdentifierNode do
      describe '#visit' do
        it 'sets the id and type members of the resource' do
          artist = Artist.new(id: 37)
          serializer = ArtistSerializer.new(artist)

          node = ResourceIdentifierNode.new(serializer)

          context = {}
          node.visit(context)

          expected = {
            id: '37',
            type: 'artists'
          }

          expect(context).to eq(expected)
        end
      end
    end
  end
end
