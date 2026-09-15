## [Unreleased]

## [0.2.1] - 2026-09-15
* Fixed usage of `ActiveSupport::Deprecation`
* Fixed a missing alias method `assert_scope_not_includes`

## [0.2.0] - 2026-09-07
### Breaking changes
* `assert_permitted_attributes` has been renamed to `assert_has_permitted_attributes` for clarity. The old method name is deprecated and will be removed in a next MINOR release.

### Improvements
* The messages of the validations have been customized. Before this, we often returned the message of the underlying assertion (ie. `assert_equal`, `assert_includes`, ...). We now have our own messages that should make it easier to understand the test failure.

## [0.1.0] - 2025-11-26

- Initial release
