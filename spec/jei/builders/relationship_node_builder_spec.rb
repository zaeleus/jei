require 'spec_helper'

module Jei
  module Builder
    describe RelationshipNodeBuilder do
      describe '.build' do
        let(:artist) { Artist.new(id: 1, albums: [Album.new(id: 1)]) }
        let(:artist_serializer) { ArtistSerializer.new(artist) }

        context 'default' do
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

        context 'relationship.options[:data] is false' do
          it 'omits the data node' do
            relationship = HasManyRelationship.new(:albums, :albums, data: false)
            node = RelationshipNodeBuilder.build(relationship, artist_serializer)

            ctx = {}
            node.visit(ctx)

            expected = { albums: {} }

            expect(ctx).to eq(expected)
          end
        end

        context 'relationship.options[:links] is set' do
          it 'adds a links node' do
            relationship = HasManyRelationship.new(:albums, :albums, links: ->(_) {
              [Link.new(:related, 'https://example.com/albums/1')]
            })

            node = RelationshipNodeBuilder.build(relationship, artist_serializer)

            ctx = {}
            node.visit(ctx)

            expected = {
              albums: {
                data: [
                  { id: '1', type: 'albums' }
                ],
                links: {
                  related: 'https://example.com/albums/1'
                }
              }
            }

            expect(ctx).to eq(expected)
          end
        end
      end
    end
  end
end
