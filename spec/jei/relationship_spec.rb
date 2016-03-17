require 'spec_helper'

module Jei
  describe Relationship do
    describe '#initialize' do
      it 'sets options[:data] to true if not set' do
        relationship = Relationship.new(:albums, :albums)
        expect(relationship.options[:data]).to be(true)

        relationship = Relationship.new(:albums, :albums, data: false)
        expect(relationship.options[:data]).to be(false)
      end
    end

    describe '#links' do
      it 'evaluates the options[:links] Proc in the context of the given serializer' do
        album = Album.new(id: 1)
        serializer = Serializer.factory(album)

        relationship = Relationship.new(:albums, :albums, links: -> {
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
