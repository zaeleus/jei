require 'spec_helper'

module Jei
  module Nodes
    describe MetaNode do
      describe '#visit' do
        it 'sets the meta member to an arbitrary object' do
          meta = { year: 2016, hello: 'world!' }

          node = MetaNode.new(meta)

          context = {}
          node.visit(context)

          expect(context).to eq({ meta: meta })
        end
      end
    end
  end
end
