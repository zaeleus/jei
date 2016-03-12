require 'spec_helper'

module Jei
  describe Document do
    describe '.new' do
      context 'always' do
        it 'initializes a DocumentNode as the root node' do
          document = Document.new
          expect(document.root).to be_kind_of(DocumentNode)
        end
      end

      context 'when passed no options' do
        it 'creates an empty root node' do
          document = Document.new
          expect(document.root.children).to be_empty
        end
      end

      context 'when options[:jsonapi] is true' do
        it 'adds a JSONAPINode to the root' do
          document = Document.new(jsonapi: true)
          expect(document.root.children.first).to be_kind_of(JSONAPINode)
        end
      end

      context 'when options[:meta] is set' do
        it 'adds a MetaNode to the root' do
          document = Document.new(meta: { foo: 'bar' })
          expect(document.root.children.first).to be_kind_of(MetaNode)
        end
      end
    end
  end
end
