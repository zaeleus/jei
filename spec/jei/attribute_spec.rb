require 'spec_helper'

module Jei
  describe Attribute do
    describe '#evaluate' do
      context '@value is a Proc' do
        it 'evaluates the value in the context of the given serializer' do
          artist = Artist.new(name: 'FIESTAR')
          serializer = ArtistSerializer.new(artist)

          f = -> (_) { "#{resource.name} is type '#{type}'" }
          attribute = Attribute.new(:message, f)

          expected = "FIESTAR is type 'artists'"
          expect(attribute.evaluate(serializer)).to eq(expected)
        end
      end

      context '@value is a symbol' do
        it "sends a message named @value to the serializer's resource" do
          artist = Artist.new(name: 'FIESTAR')
          serializer = ArtistSerializer.new(artist)

          attribute = Attribute.new(:name)

          expect(attribute.evaluate(serializer)).to eq('FIESTAR')
        end
      end
    end
  end
end
