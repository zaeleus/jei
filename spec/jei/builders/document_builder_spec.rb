require 'spec_helper'

module Jei
  module Builder
    describe DocumentBuilder do
      describe '.build' do
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
