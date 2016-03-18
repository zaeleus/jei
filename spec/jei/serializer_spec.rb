require 'spec_helper'

module Jei
  describe Serializer do
    describe '.fields' do
      it 'is cached' do
        klass = Class.new(Serializer)
        map_a = klass.fields
        map_b = klass.fields
        expect(map_a).to be(map_b)
      end
    end

    describe '.attributes' do
      it 'adds multiple attributes to the serialization map' do
        klass = Class.new(Serializer)
        klass.attributes(:kind, :name, :release_date)

        attributes = klass.fields[:attributes]

        expect(attributes[:kind]).to be_kind_of(Attribute)
        expect(attributes[:name]).to be_kind_of(Attribute)
        expect(attributes[:release_date]).to be_kind_of(Attribute)
      end
    end

    describe '.attribute' do
      it 'adds an attribute to the serialization map' do
        klass = Class.new(Serializer)
        klass.attribute(:name)

        attributes = klass.fields[:attributes]

        expect(attributes[:name]).to be_kind_of(Attribute)
      end
    end

    describe '.belongs_to' do
      it 'adds a belongs-to relationship to the serialization map' do
        klass = Class.new(Serializer)
        klass.belongs_to(:artist)

        relationships = klass.fields[:relationships]

        expect(relationships[:artist]).to be_kind_of(BelongsToRelationship)
      end
    end

    describe '.has_many' do
      it 'adds a has-many to relationship to the serialization map' do
        klass = Class.new(Serializer)
        klass.has_many(:albums)

        relationships = klass.fields[:relationships]

        expect(relationships[:albums]).to be_kind_of(HasManyRelationship)
      end
    end

    describe '.factory' do
      context 'a class is given' do
        it 'instantiates a new serializer using the given class' do
          artist = Artist.new
          serializer = Serializer.factory(artist, ArtistSerializer)
          expect(serializer).to be_kind_of(ArtistSerializer)
        end
      end

      context 'a class is not given' do
        it 'instantiates a new serializer based on the name of the resource' do
          artist = Artist.new
          serializer = Serializer.factory(artist)
          expect(serializer).to be_kind_of(ArtistSerializer)
        end
      end
    end

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

    describe '#links' do
      it 'returns nil by default' do
        artist = Artist.new
        serializer = Serializer.new(artist)
        expect(serializer.links).to be(nil)
      end
    end

    describe '#key' do
      it 'returns a (type, id) tuple' do
        artist = Artist.new(id: 1)
        serializer = Serializer.new(artist)
        expect(serializer.key).to eq(['artists', '1'])
      end
    end

    describe '#eql?' do
      it 'checks for object equality' do
        artist1 = Artist.new(id: 1)
        artist2 = Artist.new(id: 2)

        s1 = Serializer.new(artist1)
        s2 = Serializer.new(artist1)
        s3 = Serializer.new(artist2)

        expect(s1).to eql(s1)
        expect(s1).to eql(s2)
        expect(s1).not_to eql(s3)
      end
    end

    describe '#hash' do
      it 'generates a hash value for the serializer using its key' do
        artist = Artist.new(id: 1)
        serializer = Serializer.new(artist)
        expected = ['artists', '1'].hash
        expect(serializer.hash).to eq(expected)
      end
    end
  end
end
