# Jei

**Jei** is a simple serializer for Ruby that formats a JSON document described
by [JSON API][jsonapi].

[jsonapi]: http://jsonapi.org/

## Installation

Add `gem 'jei'` to your application's Gemfile or run `gem install jei` to
install it manually.

## Usage

### Quickstart

```ruby
require 'jei'

class ArtistSerializer < Jei::Serializer
  attribute :name
  has_many :albums
end

class AlbumSerializer < Jei::Serializer
  belongs_to :artist
end

class Artist < OpenStruct; end
class Album < OpenStruct; end

artist = Artist.new(id: 1, name: 'FIESTAR', albums: [])
2.times { |i| artist.albums << Album.new(id: i + 1) }

document = Jei::Document.build(artist)
document.to_json
```

This emits

```json
{
  "data": {
    "id": "1",
    "type": "artists",
    "attributes": {
      "name": "FIESTAR"
    },
    "relationships": {
      "albums": {
        "data": [
          { "id": "1", "type": "albums" },
          { "id": "2", "type": "albums" }
        ]
      }
    }
  }
}
```
