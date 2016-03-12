require 'spec_helper'

module Jei
  describe Serializer do
    describe '#id' do
      it 'returns the id of the resource as a string' do
        artist = Artist.new(id: 37)
        serializer = Serializer.new(artist)
        expect(serializer.id).to eq('37')
      end
    end

    describe '#type' do
      it 'returns the type of the resource object' do
        artist = Artist.new
        serializer = Serializer.new(artist)
        expect(serializer.type).to eq('artists')
      end
    end

    describe 'serializable maps' do
      let(:serializer_class) do
        Class.new(Serializer) do
          attributes :kind, :name, :release_date
          belongs_to :artist
          has_many :tracks
        end
      end

      let(:serializer) { serializer_class.new(Album.new) }

      describe '#attributes' do
        subject(:attributes) { serializer.attributes }

        it 'returns a map of serializable attributes' do
          expect(attributes[:kind]).to be_kind_of(Attribute)
          expect(attributes[:name]).to be_kind_of(Attribute)
          expect(attributes[:release_date]).to be_kind_of(Attribute)
        end
      end

      describe '#relationships' do
        subject(:relationships) { serializer.relationships }

        it 'returns a map of serializable relationships' do
          expect(relationships[:artist]).to be_kind_of(BelongsToRelationship)
          expect(relationships[:tracks]).to be_kind_of(HasManyRelationship)
         end
      end
    end
  end
end
