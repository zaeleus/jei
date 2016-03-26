require 'spec_helper'

module Jei
  describe Document do
    describe '.build' do
      context 'the resource is nil' do
        it 'adds an empty data node' do
          document = Document.build(nil)
          expected = { data: nil }
          expect(document.to_h).to eq(expected)
        end
      end

      context 'the resource is a collection' do
        it 'adds a collection data node' do
          artist_serializer_class = Class.new(Serializer)
          artists = [Artist.new(id: 1), Artist.new(id: 2)]

          document = Document.build(artists, serializer: artist_serializer_class)

          expected = {
            data: [
              { id: '1', type: 'artists' },
              { id: '2', type: 'artists' }
            ]
          }

          expect(document.to_h).to eq(expected)
        end
      end

      context 'options[:fields] is a map of fieldsets' do
        let(:artist) do
          albums = [Album.new(id: 1, name: 'A Delicate Sense')]
          Artist.new(id: 1, kind: :group, name: 'FIESTAR', albums: albums)
        end

        it 'only includes the specified fields' do
          fields = { 'artists' => 'name', 'albums' => '' }
          document = Document.build(artist, fields: fields, include: 'albums')

          expected = {
            data: {
              id: '1',
              type: 'artists',
              attributes: {
                name: 'FIESTAR'
              }
            },
            included: [
              { id: '1', type: 'albums' }
            ]
          }

          expect(document.to_h).to eq(expected)
        end
      end

      context 'options[:include] is a string of relationship paths' do
        let(:artists) do
          artist1 = Artist.new(id: 1)
          artist1.albums = [Album.new(id: 1, artist: artist1)]

          artist2 = Artist.new(id: 2)
          artist2.albums = [Album.new(id: 2, artist: artist2)]

          [artist1, artist2]
        end

        let(:artist_serializer_class) do
          Class.new(Serializer) do
            has_many :albums, serializer: Class.new(Serializer)
          end
        end

        context 'the resource is singular' do
          it 'includes related resources in an included node' do
            options = { include: 'albums', serializer: artist_serializer_class }
            document = Document.build(artists[0], options)

            expected = {
              data: {
                id: '1',
                type: 'artists',
                relationships: {
                  albums: { data: [{ id: '1', type: 'albums' }] }
                }
              },
              included: [{ id: '1', type: 'albums' }]
            }

            expect(document.to_h).to eq(expected)
          end
        end

        context 'the resource is a collection' do
          it 'includes all related resources in an included node' do
            options = { include: 'albums', serializer: artist_serializer_class }
            document = Document.build(artists, options)

            expected = {
              data: [{
                id: '1',
                type: 'artists',
                relationships: {
                  albums: { data: [{ id: '1', type: 'albums' }] }
                }
              }, {
                id: '2',
                type: 'artists',
                relationships: {
                  albums: { data: [{ id: '2', type: 'albums' }] }
                }
              }],
              included: [
                { id: '1', type: 'albums' },
                { id: '2', type: 'albums' }
              ]
            }

            expect(document.to_h).to eq(expected)
          end
        end
      end

      context 'options[:jsonapi] is true' do
        it 'adds a jsaonapi node to the document' do
          document = Document.build(nil, jsonapi: true)

          expected = {
            jsonapi: {
              version: '1.0'
            },
            data: nil
          }

          expect(document.to_h).to eq(expected)
        end
      end

      context 'options[:links] is a list of links' do
        it 'adds a links node do the document' do
          links = [Link.new(:self, 'https://example.com/artists')]
          document = Document.build(nil, links: links)

          expected = {
            links: {
              self: 'https://example.com/artists'
            },
            data: nil
          }

          expect(document.to_h).to eq(expected)
        end
      end

      context 'options[:meta] is an hash' do
        it 'adds a meta node to the document' do
          meta = { total_pages: 10 }
          document = Document.build(nil, meta: meta)

          expected = {
            meta: meta,
            data: nil
          }

          expect(document.to_h).to eq(expected)
        end
      end

      context 'options[:serializer] is set to a Serializer class' do
        it 'uses the given serializer class rather than Serializer.factory' do
          artist = Artist.new(id: 1, name: 'FIESTAR')
          serializer_class = Class.new(Serializer) { attributes :name }

          document = Document.build(artist, serializer: serializer_class)
          data = document.to_h

          expected = {
            data: {
              id: '1',
              type: 'artists',
              attributes: {
                name: 'FIESTAR'
              }
            }
          }

          expect(data).to eq(expected)
        end
      end
    end

    describe '.new' do
      it 'initializes an empty hash as the root' do
        document = Document.new
        expect(document.root).to eq({})
      end
    end

    describe '#to_h' do
      it 'returns the document as a hash' do
        document = Document.new
        expect(document.to_h).to eq({})
      end
    end

    describe '#to_json' do
      it 'formats the document as a JSON string' do
        document = Document.new
        expect(document.to_json).to eq('{}')
      end
    end
  end
end
