require 'spec_helper'

module Jei
  module Builder
    describe RelationshipNodeBuilder do
      describe '.build' do
        let(:artist) { Artist.new(id: 1, albums: [Album.new(id: 1)]) }
        let(:artist_serializer) { ArtistSerializer.new(artist) }

        it 'builds a relationship node' do
          relationship = HasManyRelationship.new(:albums)

          node = RelationshipNodeBuilder.build(relationship, artist_serializer)

          ctx = {}
          node.visit(ctx)

          expected = {
            albums: {
              data: [
                { id: '1', type: 'albums' }
              ]
            }
          }

          expect(ctx).to eq(expected)
        end
      end
    end
  end
end
