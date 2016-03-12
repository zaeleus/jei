require 'spec_helper'

module Jei
  describe DataNode do
    describe '#visit' do
      context 'when the node has no children' do
        it 'sets the data member to nil' do
          node = DataNode.new

          context = {}
          node.visit(context)

          expect(context).to eq({ data: nil })
        end
      end

      context 'the node has children' do
        it 'visits each child' do
          node = DataNode.new
          node.children << MetaNode.new({ foo: 'bar' })

          context = {}
          node.visit(context)

          expected = {
            data: {
              meta: {
                foo: 'bar'
              }
            }
          }

          expect(context).to eq(expected)
        end
      end
    end
  end
end
