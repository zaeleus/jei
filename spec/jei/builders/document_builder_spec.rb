require 'spec_helper'

module Jei
  module Builder
    describe DocumentBuilder do
      describe '.build' do
        context 'the resource is nil' do
          it 'adds an empty data node' do
            document = DocumentBuilder.build(nil)
            expected = { data: nil }
            expect(document.to_h).to eq(expected)
          end
        end

        context 'options[:jsonapi] is true' do
          it 'adds a jsaonapi node to the document' do
            document = DocumentBuilder.build(nil, jsonapi: true)

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
            document = DocumentBuilder.build(nil, links: links)

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
            document = DocumentBuilder.build(nil, meta: meta)

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

            document = DocumentBuilder.build(artist, serializer: serializer_class)
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
    end
  end
end
