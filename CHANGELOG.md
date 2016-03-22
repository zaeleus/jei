# Changelog

## HEAD

## 0.2.0 (2016-03-22)

* [ADD] Add `:fields` document build option for sparse fieldsets.
* [BREAKING] A relationship links `Proc` is no longer passed the context as
  an argument. Update usages of `links: ->(_) {}` to `links: -> {}`.
* [ADD] Raise `Jei::Path::NameError` on bad relationship names.
* [BREAKING] Rename relationship option `no_data` to `data`. Take the
  inverse of each occurance to update, e.g., change `no_data: true` to
  `data: false`.
* [ADD] Add `:serializer` option to relationships to override the default
  serializer class used.
* [CHANGE] Serializers are compared via a `(type, id)` tuple rather than
  object identity.
* [FIX] Fix include usage when serializing a collection.

## 0.1.0 (2016-03-15)

* Initial release
