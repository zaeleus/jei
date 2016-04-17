require 'spec_helper'

module Jei
  class Document
    describe Builder do
      describe '.build_json_api' do
        it 'builds a JSON API object' do
          root = {}
          Builder.build_json_api(root)

          expected = {
            jsonapi: {
              version: '1.0'
            }
          }

          expect(root).to eq(expected)
        end
      end

      describe '.build_meta' do
        it 'builds a meta object' do
          meta = { name: 'FIESTAR' }

          root = {}
          Builder.build_meta(root, meta)

          expected = {
            meta: {
              name: 'FIESTAR'
            }
          }

          expect(root).to eq(expected)
        end
      end

      describe '.build_links' do
        it 'builds a links object' do
          links = [
            Link.new(:self, '/artists/1/relationships/albums'),
            Link.new(:related, '/artists/1/albums')
          ]

          root = {}
          Builder.build_links(root, links)

          expected = {
            links: {
              self: '/artists/1/relationships/albums',
              related: '/artists/1/albums'
            }
          }

          expect(root).to eq(expected)
        end
      end

      describe '.build_link' do
        context 'the link has no metadata' do
          it 'represents the link as a string' do
            link = Link.new(:self, '/artists')

            root = {}
            Builder.build_link(root, link)

            expected = { self: '/artists' }

            expect(root).to eq(expected)
          end
        end

        context 'the link has metadata' do
          it 'represents the link as an object with href and meta members' do
            link = Link.new(:self, '/artists', { count: 10 })

            root = {}
            Builder.build_link(root, link)

            expected = {
              self: {
                href: '/artists',
                meta: {
                  count: 10
                }
              }
            }

            expect(root).to eq(expected)
          end
        end
      end

      describe '.build_single' do
        let(:artist) { Artist.new(id: 1, albums: [Album.new(id: 1)]) }

        context 'by default' do
          it "builds the document's primary data from a single resource" do
            artist_serializer_class = Class.new(Serializer)

            root = {}
            options = { serializer: artist_serializer_class }
            Builder.build_single(root, artist, options)

            expected = {
              data: {
                id: '1',
                type: 'artists'
              }
            }

            expect(root).to eq(expected)
          end
        end

        context 'options[:include] is set' do
          it 'builds a compound document with included resources' do
            album_serializer_class = Class.new(Serializer)
            artist_serializer_class = Class.new(Serializer) do
              has_many :albums, serializer: album_serializer_class
            end

            root = {}
            options = { include: 'albums', serializer: artist_serializer_class }
            Builder.build_single(root, artist, options)

            expected = {
              data: {
                id: '1',
                type: 'artists',
                relationships: {
                  albums: {
                    data: [{
                      id: '1',
                      type: 'albums'
                    }]
                  }
                }
              },
              included: [{
                id: '1',
                type: 'albums'
              }]
            }

            expect(root).to eq(expected)
          end
        end
      end

      describe '.build_collection' do
        let(:artists) do
          2.times.map do |i|
            Artist.new(id: i + 1, albums: [Album.new(id: i + 1)])
          end
        end

        context 'by default' do
          it "builds the document's primary data from a collection" do
            artist_serializer_class = Class.new(Serializer)

            root = {}
            options = { serializer: artist_serializer_class }
            Builder.build_collection(root, artists, options)

            expected = {
              data: [{
                id: '1',
                type: 'artists'
              }, {
                id: '2',
                type: 'artists'
              }]
            }

            expect(root).to eq(expected)
          end
        end

        context 'options[:include] is set' do
          it 'builds a compound document with included resources' do
            album_serializer_class = Class.new(Serializer)
            artist_serializer_class = Class.new(Serializer) do
              has_many :albums, serializer: album_serializer_class
            end

            root = {}
            options = { include: 'albums', serializer: artist_serializer_class }
            Builder.build_collection(root, artists, options)

            expected = {
              data: [{
                id: '1',
                type: 'artists',
                relationships: {
                  albums: {
                    data: [{
                      id: '1',
                      type: 'albums'
                    }]
                  }
                }
              }, {
                id: '2',
                type: 'artists',
                relationships: {
                  albums: {
                    data: [{
                      id: '2',
                      type: 'albums'
                    }]
                  }
                }
              }],
              included: [{
                id: '1',
                type: 'albums'
              }, {
                id: '2',
                type: 'albums'
              }]
            }

            expect(root).to eq(expected)
          end
        end
      end

      describe '.build_resource_identifier' do
        it 'builds an identifier object' do
          artist = Artist.new(id: 1)
          artist_serializer_class = Class.new(Serializer)
          serializer = artist_serializer_class.new(artist)

          root = {}
          Builder.build_resource_identifier(root, serializer)

          expected = {
            id: '1',
            type: 'artists'
          }

          expect(root).to eq(expected)
        end
      end

      describe '.build_resource' do
        let(:fieldset) { nil }

        context 'default' do
          it 'builds a resource identifier' do
            artist = Artist.new(id: 1)
            artist_serializer_class = Class.new(Serializer)
            serializer = artist_serializer_class.new(artist)

            root = {}
            Builder.build_resource(root, serializer, fieldset)

            expected = {
              id: '1',
              type: 'artists'
            }

            expect(root).to eq(expected)
          end
        end

        context 'the serializer has attributes' do
          it 'builds a attributes object' do
            artist = Artist.new(id: 1, name: 'FIESTAR')
            artist_serializer_class = Class.new(Serializer) { attribute :name }
            serializer = artist_serializer_class.new(artist)

            root = {}
            Builder.build_resource(root, serializer, fieldset)

            expected = {
              id: '1',
              type: 'artists',
              attributes: {
                name: 'FIESTAR'
              }
            }

            expect(root).to eq(expected)
          end
        end

        context 'the serializer has relationships' do
          it 'builds a relationships object' do
            artist = Artist.new(id: 1)
            album = Album.new(id: 1, artist: artist)

            artist_serializer_class = Class.new(Serializer)
            album_serializer_class = Class.new(Serializer) do
              belongs_to :artist, serializer: artist_serializer_class
            end

            serializer = album_serializer_class.new(album)

            root = {}
            Builder.build_resource(root, serializer, fieldset)

            expected = {
              id: '1',
              type: 'albums',
              relationships: {
                artist: {
                  data: {
                    id: '1',
                    type: 'artists'
                  }
                }
              }
            }

            expect(root).to eq(expected)
          end
        end

        context 'the serializer has links' do
          it 'builds a links object' do
            artist = Artist.new(id: 1)

            artist_serializer_class = Class.new(Serializer) do
              def links
                [Link.new(:self, "/artists/#{id}")]
              end
            end

            serializer = artist_serializer_class.new(artist)

            root = {}
            Builder.build_resource(root, serializer, fieldset)

            expected = {
              id: '1',
              type: 'artists',
              links: {
                self: '/artists/1'
              }
            }

            expect(root).to eq(expected)
          end
        end
      end

      describe '.build_attributes' do
        it 'builds an attribute object' do
          attributes = [Attribute.new(:name), Attribute.new(:kind)]

          artist = Artist.new(id: 1, name: 'FIESTAR', kind: :group)
          artist_serializer_class = Class.new(Serializer)
          serializer = artist_serializer_class.new(artist)

          root = {}
          Builder.build_attributes(root, attributes, serializer)

          expected = {
            attributes: {
              name: 'FIESTAR',
              kind: :group
            }
          }

          expect(root).to eq(expected)
        end
      end

      describe '.build_relationships' do
        it 'builds a relationships object' do
          artist = Artist.new(id: 1)
          album = Album.new(id: 1, artist: artist)

          artist_serializer_class = Class.new(Serializer)
          album_serializer_class = Class.new(Serializer) do
            belongs_to :artist, serializer: artist_serializer_class
          end

          serializer = album_serializer_class.new(album)
          relationships = serializer.relationships.values

          root = {}
          Builder.build_relationships(root, relationships, serializer)

          expected = {
            relationships: {
              artist: {
                data: {
                  id: '1',
                  type: 'artists'
                }
              }
            }
          }

          expect(root).to eq(expected)
        end
      end

      describe '.build_relationship' do
        context 'the relationship is a belongs-to relationship' do
          it 'builds a resource link for a single resource' do
            artist = Artist.new(id: 1)
            album = Album.new(id: 1, artist: artist)

            artist_serializer_class = Class.new(Serializer)
            album_serializer_class = Class.new(Serializer) do
              belongs_to :artist, serializer: artist_serializer_class
            end

            serializer = album_serializer_class.new(album)
            relationship = serializer.relationships[:artist]

            root = {}
            Builder.build_relationship(root, relationship, serializer)

            expected = {
              artist: {
                data: {
                  id: '1',
                  type: 'artists'
                }
              }
            }

            expect(root).to eq(expected)
          end
        end

        context 'the relationship is a has-many relationship' do
          it 'builds related resource links for a collection' do
            albums = [Album.new(id: 1), Album.new(id: 2)]
            artist = Artist.new(id: 1, albums: albums)

            album_serializer_class = Class.new(Serializer)
            artist_serializer_class = Class.new(Serializer) do
              has_many :albums, serializer: album_serializer_class
            end

            serializer = artist_serializer_class.new(artist)
            relationship = serializer.relationships[:albums]

            root = {}
            Builder.build_relationship(root, relationship, serializer)

            expected = {
              albums: {
                data: [{
                  id: '1',
                  type: 'albums'
                }, {
                  id: '2',
                  type: 'albums'
                }]
              }
            }

            expect(root).to eq(expected)
          end
        end

        context 'the relationship is invalid' do
          it 'raises an ArgumentError' do
            relationship = Relationship.new(:albums)
            serializer = Serializer.new(Artist.new(id: 1, albums: []))

            expect {
              Builder.build_relationship({}, relationship, serializer)
            }.to raise_error(ArgumentError)
          end
        end

        context 'relationship.options[:data] is false' do
          let(:artist) { Artist.new(id: 1, albums: []) }

          let(:serializer_class) do
            Class.new(Serializer) do
              has_many :albums, data: false
            end
          end

          it 'does not build resource links' do
            serializer = serializer_class.new(artist)
            relationship = serializer.relationships[:albums]

            root = {}
            Builder.build_relationship(root, relationship, serializer)

            expected = {
              albums: {}
            }

            expect(root).to eq(expected)
          end

          it 'can be overridden if the serializer has the relationship tagged for full linkage' do
            serializer = serializer_class.new(artist)
            serializer.options[:linkages] = Set.new([:albums])

            relationship = serializer.relationships[:albums]

            root = {}
            Builder.build_relationship(root, relationship, serializer)

            expected = {
              albums: {
                data: []
              }
            }

            expect(root).to eq(expected)
          end
        end

        context 'relationship.options[:links] is set' do
          it 'builds a links object' do
            artist = Artist.new(id: 1, albums: [])

            artist_serializer_class = Class.new(Serializer) do
              has_many :albums, links: -> {
                [Link.new(:related, '/artists/1/albums')]
              }
            end

            serializer = artist_serializer_class.new(artist)
            relationship = serializer.relationships[:albums]

            root = {}
            Builder.build_relationship(root, relationship, serializer)

            expected = {
              albums: {
                data: [],
                links: {
                  related: '/artists/1/albums'
                }
              }
            }

            expect(root).to eq(expected)
          end
        end
      end

      describe '.build_belongs_to_relationship' do
        it 'builds a resource link for a resource' do
          artist = Artist.new(id: 1)
          album = Album.new(id: 1, artist: artist)

          artist_serializer_class = Class.new(Serializer)
          album_serializer_class = Class.new(Serializer) do
            belongs_to :artist, serializer: artist_serializer_class
          end

          serializer = album_serializer_class.new(album)
          relationship = serializer.relationships[:artist]

          root = {}
          Builder.build_belongs_to_relationship(root, relationship, serializer)

          expected = {
            data: {
              id: '1',
              type: 'artists'
            }
          }

          expect(root).to eq(expected)
        end
      end

      describe '.build_has_many_relationship' do
        it 'builds resource links for a collection' do
          albums = [Album.new(id: 1), Album.new(id: 2)]
          artist = Artist.new(id: 1, albums: albums)

          album_serializer_class = Class.new(Serializer)
          artist_serializer_class = Class.new(Serializer) do
            has_many :albums, serializer: album_serializer_class
          end

          serializer = artist_serializer_class.new(artist)
          relationship = serializer.relationships[:albums]

          root = {}
          Builder.build_has_many_relationship(root, relationship, serializer)

          expected = {
            data: [{
              id: '1',
              type: 'albums'
            }, {
              id: '2',
              type: 'albums'
            }]
          }

          expect(root).to eq(expected)
        end
      end

      describe '.build_included' do
        it 'builds included resources' do
          artist = Artist.new(id: 1)
          artist_serializer_class = Class.new(Serializer)
          serializer = artist_serializer_class.new(artist)

          serializers = Set.new
          serializers << serializer

          fieldsets = {}

          root = {}
          Builder.build_included(root, serializers, fieldsets)

          expected = {
            included: [{
              id: '1',
              type: 'artists'
            }]
          }
        end
      end

      describe '.build_errors' do
        it 'builds an array of error objects' do
          errors = [{
            status: '400'
          }]

          root = {}
          Builder.build_errors(root, errors)

          expected = {
            errors: [{
              status: '400'
            }]
          }

          expect(root).to eq(expected)
        end
      end
    end
  end
end
