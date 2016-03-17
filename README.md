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

# Create resource serializers.
class ArtistSerializer < Jei::Serializer
  attribute :name
  has_many :albums
end

class AlbumSerializer < Jei::Serializer
  belongs_to :artist
end

artist = Artist.new(id: 1, name: 'FIESTAR', albums: [])
artist.albums << Album.new(id: 1, artist: artist)
artist.albums << Album.new(id: 2, artist: artist)

# Build a JSON API document from the resource.
document = Jei::Document.build(artist)
document.to_json
```

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

### Serializers

A `Serializer` defines what attributes and relationships are serialized in a
document.

Jei uses reflection to automatically find the correct serailizer for a
resource. To do this, create a class that extends `Jei::Serializer` and name it
`#{resource.class.name}Serializer`. For example, an `Artist` resource would
have a matching serializer named `ArtistSerializer` in the global namespace.

```ruby
class Artist; end
class ArtistSerializer < Jei::Serializer; end
```

#### Attributes

Attributes represent model data. They are defined in a serializer by using the
`attribute` or `attributes` methods.

```ruby
class AlbumSerializer < Jei::Serializer
  # Attributes can be listed by name. Each name is used as an attribute key
  # and its value is invoked by its name on the resource.
  attributes :kind, :name

  # Attributes can also be added individually.
  attribute :released_on

  # This is useful because `attribute` optionally takes a block. It can be
  # used to rename an attribute in the document when the resource responds to
  # a different name.
  attribute(:release_date) { resource.released_on }

  # Or it can be use to create entirely new attributes and values.
  attribute :formatted_name do
    date = resource.released_on.strftime('%Y.%m.%d')
    "[#{date}] #{resource.name}"
  end
end

album = Album.new(id: 1, kind: :ep, name: 'A Delicate Sense', released_on: Date.new(2016, 3, 9))
Jei::Document.build(album).to_json
```

```json
{
  "data": {
    "id": "1",
    "type": "albums",
    "attributes": {
      "kind": "ep",
      "name": "A Delicate Sense",
      "released_on": "2016-03-09",
      "release_date": "2016-03-09",
      "formatted_name": "[2016.03.09] A Delicate Sense"
    }
  }
}
```

#### Relationships

Relationships describe how the primary resource relates to other resources. A
one-to-one relationship is defined by the `belongs_to` method, and a
one-to-many relationship, `has_many`.

The relationship names are invoked on the resource. A
belongs-to relationship returns a single resource, whereas has-many returns a
collection.

```ruby
class AlbumSerializer < Jei::Serializer
  belongs_to :artist
  has_many :tracks

  # Like attributes, relationships can also take a block to override its value.
  has_many :even_tracks do
    resource.tracks.select { |t| t.id.even? }
  end
end

class ArtistSerializer < Jei::Serializer; end
class TrackSerializer < Jei::Serializer; end

artist = Artist.new(id: 1)
tracks = [Track.new(id: 1), Track.new(id: 2)]
album = Album.new(id: 1, artist: artist, tracks: tracks)

Jei::Document.build(album).to_json
```

```json
{
  "data": {
    "id": "1",
    "type": "albums",
    "relationships": {
      "artist": {
        "data": { "id": "1", "type": "artists" }
      },
      "tracks": {
        "data": [
          { "id": "1", "type": "tracks" },
          { "id": "2", "type": "tracks" }
        ]
      },
      "even_tracks": {
        "data": [
          { "id": "2", "type": "tracks" }
        ]
      }
    }
  }
}
```

##### Options

Each relationship object can be modified with the following options.

* `data`: (`Boolean`; default: `true`) Setting this to `false` supresses
  building a data object with resource identifiers. Note that doing so does not
  emit a valid JSON API document unless a links or meta object is present.

    ```ruby
    class ArtistSerializer < Jei::Serializer
      has_many :albums, data: false
    end

    albums = [Album.new(id: 1), Album.new(id: 2)]
    artist = Artist.new(id: 1, albums: albums)

    Jei::Document.build(artist).to_json
    ```

    ```json
    {
      "data": {
        "id": "1",
        "type": "artists",
        "relationships": {
          "albums": {}
        }
      }
    }
    ```

* `links`: (`Proc -> Array<Jei::Link>`) This is for relationship level links.
  The `Proc` must return a list of `Link`s and is run in the context of the
  serializer.

    ```ruby
    class ArtistSerializer < Jei::Serializer
      has_many :albums, links: ->(_) {
        [Jei::Link.new(:related, "/#{type}/#{id}/albums")]
      }
    end

    class AlbumSerializer < Jei::Serializer; end

    albums = [Album.new(id: 1), Album.new(id: 2)]
    artist = Artist.new(id: 1, albums: albums)
    Jei::Document.build(artist).to_json
    ```

    ```json
    {
      "data": {
        "id": "1",
        "type": "artists",
        "relationships": {
          "albums": {
            "data": [
              { "id": "1", "type": "albums" },
              { "id": "2", "type": "albums" }
            ],
            "links": {
              "related": "/artists/1/albums"
            }
          }
        }
      }
    }
    ```

* `serializer`: (`Class`) Overrides the default serializer used for each
  related resource.

    ```ruby
    class RecordSerializer < Jei::Serializer
      def type
        'records'
      end
    end

    class ArtistSerializer < Jei::Serializer
      has_many :albums, serializer: RecordSerializer
    end

    artist = Artist.new(id: 1, albums: [Album.new(id: 1)])
    Jei::Document.build(artist).to_json
    ```

    ```json
    {
      "data": {
        "id": "1",
        "type": "artists",
        "relationships": {
          "albums": {
            "data": [
              { "id": "1", "type": "records" }
            ]
          }
        }
      }
    }
    ```

### Document

As seen in previous examples, `Jei::Document` represents a JSON API document.
After building the structure from a resource or collection of resources using
`Document.build`, it can be serialized to a Ruby hash (`#to_h`) or a JSON
string (`#to_json`).

#### Options

Top level objects can be added using the following options.

* `:include`: (`String`) A comma separated list of relationship paths. Each
  path is a list of relationship names, separated by a period. For example, a
  valid list of paths would be `artist,tracks.song`. The set of resources are
  all unique resources on the include path.

    ```ruby
    class ArtistSerializer < Jei::Serializer
      attribute :name
      has_many :albums
    end

    class AlbumSerializer < Jei::Serializer
      attributes :name, :release_date
      belongs_to :artist
      has_many :tracks
    end

    class TrackSerializer < Jei::Serializer
      attributes :position, :name
      belongs_to :album
    end

    artist = Artist.new(id: 1, name: 'FIESTAR')
    album1 = Album.new(id: 1, name: 'A Delicate Sense', release_date: '2016-03-09', artist: artist)
    album2 = Album.new(id: 2, name: 'Black Label', release_date: '2015-03-04', artist: artist)
    artist.albums = [album1, album2]
    album1.tracks = [Track.new(id: 1, position: 2, name: 'Mirror', album: album1)]
    album2.tracks = [Track.new(id: 2, position: 1, name: "You're Pitiful", album: album2)]

    Jei::Document.build(artist, include: 'albums.tracks').to_json
    ```

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
      },
      "included": [
        {
          "id": "1",
          "type": "albums",
          "attributes": {
            "name": "A Delicate Sense",
            "release_date": "2016-03-09"
          },
          "relationships": {
            "artist": {
              "data": { "id": "1", "type": "artists" }
            },
            "tracks": {
              "data": [
                { "id": "1", "type": "tracks" }
              ]
            }
          }
        },
        // ...
      ]
    }
    ```

* `:jsonapi`: (`Boolean`) Includes a JSON API object in top level of the
  document.

    ```ruby
    Jei::Document.build(nil, jsonapi: true).to_json
    ```

    ```json
    {
      "jsonapi": {
        "version": "1.0"
      },
      "data": null
    }
    ```

* `:links`: (`Array<Link>`) Includes a links object in the top level of the
  document.

    ```ruby
    links = [
      Jei::Link.new(:self, '/artists?page[number]=2'),
      Jei::Link.new(:prev, '/artists?page[number]=1'),
      Jei::Link.new(:next, '/artists?page[number]=3')
    ]
    Jei::Document.build(nil, links: links).to_json
    ```

    ```json
    {
      "links": {
        "self": "/artists?page[number]=2",
        "prev": "/artists?page[number]=1",
        "next": "/artists?page[number]=3"
      },
      "data": null
    }
    ```

* `:meta`: (`Hash<Symbol, Object>`) Includes a meta object in the top level of
  the document.

    ```ruby
    Jei::Document.build(nil, meta: { total_pages: 10 }).to_json
    ```

    ```json
    {
      "meta": {
        "total_pages": 10
      },
      "data": null
    }
    ```

* `:serializer`: (`Class`) Overrides the default serializer used for the
  primary resource.

    ```ruby
    class SimpleArtistSerializer < Jei::Serializer
      attribute :name
    end

    artist = Artist.new(id: 1, name: 'FIESTAR')
    Jei::Document.build(artist, serializer: SimpleArtistSerializer).to_json
    ```

    ```json
    {
      "data": {
        "id": "1",
        "type": "artists",
        "attributes": {
          "name": "FIESTAR"
        }
      }
    }
    ```

## Integration

Jei is not tied to any framework and can be integrated as a normal gem.

### Rails

The simplest usage with [Rails][rails] is to define a new renderer.

```ruby
# config/initializers/jei.rb
ActionController::Renderers.add(:jsonapi) do |resource, options|
  document = Jei::Document.build(resource, options)
  json = document.to_json
  self.content_type = Mime::Type.lookup_by_extension(:jsonapi)
  self.response_body = json
end

# config/initializers/mime_types.rb
Mime::Type.register 'application/vnd.api+json', :jsonapi
```

Serializers can be placed in `app/serializers`. Include Rails' url helpers to
have them conveniently accessible in the serializer context for links.

```ruby
# app/serializers/application_serializer.rb
class ApplicationSerializer < Jei::Serializer
  include Rails.application.routes.url_helpers
end

# app/serializers/album_serializer.rb
class AlbumSerializer < ApplicationSerializer
  attributes :kind, :name, :release_date
  belongs_to :artist
end

# app/serializers/artist_serializer.rb
class ArtistSerializer < ApplicationSerializer
  attributes :name
  has_many :albums, data: false, links: ->(_) {
    [Jei::Link.new(:related, album_path(resource))]
  }
end
```

Specify the `jsonapi` format defined earlier when rendering in a controller.

```ruby
# app/controllers/artists_controller.rb
class ArtistsController < ApplicationController
  def show
    artist = Artist.find(params[:id])
    render jsonapi: artist, include: params[:include]
  end
end
```

[rails]: http://rubyonrails.org/
