require 'spec_helper'

module Jei
  describe LinkNode do
    describe '#visit' do
      context 'the link has no meta' do
        it "sets the link's href" do
          link = Link.new(:related, 'https://example.com/artists')
          node = LinkNode.new(link)

          context = {}
          node.visit(context)

          expected = {
            related: 'https://example.com/artists'
          }

          expect(context).to eq(expected)
        end
      end

      context 'the link has meta' do
        it 'sets a link object' do
          link = Link.new(:related, 'https://example.com/artists', count: 5)

          node = LinkNode.new(link)

          context = {}
          node.visit(context)

          expected = {
            related: {
              href: 'https://example.com/artists',
              meta: {
                count: 5
              }
            }
          }

          expect(context).to eq(expected)
        end
      end
    end
  end
end
