# Changelog

## HEAD

* [BREAKING] Rename relationship option `no_data` to `data`. Take the
  inverse of each occurance to update, e.g., change `no_data: true` to
  `data: false`.
* [ADD] Add `:serializer` option to relationships to override the default
  serializer class used.
* [CHANGE] Resources are compared via a `(type, id)` tuple rather than
  object identity.
* [FIX] Fix include usage when serializing a collection.

## 0.1.0 (2016-03-16)

* Initial release
