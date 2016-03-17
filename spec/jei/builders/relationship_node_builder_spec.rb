require 'spec_helper'

module Jei
  module Builders
    describe RelationshipNodeBuilder do
      describe '.build' do
        let(:resources) do
          r = {}
          r[:artist] = Artist.new(id: 1, albums: [])
          r[:album] = Album.new(id: 1, artist: r[:artist])
          r[:artist].albums << r[:album]
          r
        end

        let(:artist) { resources[:artist] }
        let(:album) { resources[:album] }

        let(:artist_serializer) { ArtistSerializer.new(artist) }
        let(:album_serializer) { AlbumSerializer.new(album) }

        context 'default' do
          context 'given a belongs-to relationship' do
            it 'adds a data node with a resource identifier' do
              relationship = BelongsToRelationship.new(:artist)
              node = RelationshipNodeBuilder.build(relationship, album_serializer)

              ctx = {}
              node.visit(ctx)

              expected = {
                artist: {
                  data: { id: '1', type: 'artists' }
                }
              }

              expect(ctx).to eq(expected)
            end
          end

          context 'given a has-many relationship' do
            it 'adds a collection data node of resource identifiers' do
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

          context 'given an unknown relationship' do
            it 'raises an error' do
              relationship = Relationship.new(:albums)

              expect {
                RelationshipNodeBuilder.build(relationship, artist_serializer)
              }.to raise_error(ArgumentError)
            end
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
            relationship = HasManyRelationship.new(:albums, :albums, links: proc {
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
