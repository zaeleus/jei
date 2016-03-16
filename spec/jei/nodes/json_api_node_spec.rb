require 'spec_helper'

module Jei
  module Nodes
    describe AttributeNode do
      describe '#visit' do
        it 'builds a JSON API object' do
          node = JSONAPINode.new

          context = {}
          node.visit(context)

          expected = {
            jsonapi: {
              version: '1.0'
            }
          }

          expect(context).to eq(expected)
        end
      end
    end
  end
end
