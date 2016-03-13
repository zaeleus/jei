require 'spec_helper'

module Jei
  describe Relationship do
    describe '#links' do
      it 'evaluates the options[:links] Proc in the context of the given serializer' do
        album = Album.new(id: 1)
        serializer = Serializer.factory(album)

        relationship = Relationship.new(:albums, :albums, links: -> (_) {
          [Link.new(:related, "/api/v1/#{type}")]
        })

        links = relationship.links(serializer)
        link = links.first

        expect(link.name).to eq(:related)
        expect(link.href).to eq('/api/v1/albums')
      end
    end
  end
end
