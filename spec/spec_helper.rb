$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jei'
require 'ostruct'

class Artist < OpenStruct; end
class Album < OpenStruct; end

class ArtistSerializer < Jei::Serializer
  attributes :kind, :name
end
