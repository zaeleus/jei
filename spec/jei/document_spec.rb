require 'spec_helper'

module Jei
  describe Document do
    describe '.new' do
      it 'initializes a DocumentNode as the root node' do
        document = Document.new
        expect(document.root).to be_kind_of(DocumentNode)
      end
    end
  end
end
