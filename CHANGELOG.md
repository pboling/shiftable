## [Unreleased]

### Added


### Changed


### Fixed


### Removed


## [0.7.0] - 2021-11-15
### Changed

- Make the `Shifting` Relation available to the `each` wrapper, as a block parameter

## [0.6.1] - 2021-11-14
### Added

- Support for using save with bang (`save!`) to raise error when ActiveRecord save fails.

## [0.6.0] - 2021-11-12
### Added

- Support for wrappers/hooks around each record shift, and around the entire set (see examples in specs or README)

## [0.5.1] - 2021-11-12
### Fixed

- Documentation typos in README

## [0.5.0] - 2021-11-12
### Added

- Support for Polymorphic associations (see examples in specs or README)

## [0.4.1] - 2021-11-10
### Fixed

- Documentation typos in README

## [0.4.0] - 2021-10-27
### Changed

- option :preflight_checks renamed to :precheck

### Added

- Even more 100% spec coverage

## [0.3.0] - 2021-10-26
### Changed

- Internal rewrite to improve maintainability
- Extreme edge cases involving incorrect configuration will raise slightly different errors.

### Added

- Even more 100% spec coverage

## [0.2.0] - 2021-10-24
### Changed

- option `before_save` is now `before_shift` as originally documented

### Updated

- Github Actions now test all supported Rubies
- Linting
- Documentation

## [0.1.1] - 2021-10-23
### Fixed

- Github Actions build

### Updated

- Linting

## [0.1.0] - 2021-10-23
### Added

- Initial release
- feat: supports shifting of records associated as has_one / belongs_to and has_many / belongs_to, including with STI.
- 100% test coverage

[0.1.0]: https://github.com/pboling/shiftable/releases/tag/v0.1.0

[0.1.1]: https://github.com/pboling/shiftable/releases/tag/v0.1.1

[0.2.0]: https://github.com/pboling/shiftable/releases/tag/v0.2.0

[0.3.0]: https://github.com/pboling/shiftable/releases/tag/v0.3.0

[0.4.0]: https://github.com/pboling/shiftable/releases/tag/v0.4.0

[0.4.1]: https://github.com/pboling/shiftable/releases/tag/v0.4.1

[0.5.0]: https://github.com/pboling/shiftable/releases/tag/v0.5.0

[0.5.1]: https://github.com/pboling/shiftable/releases/tag/v0.5.1

[0.6.0]: https://github.com/pboling/shiftable/releases/tag/v0.6.0

[0.6.1]: https://github.com/pboling/shiftable/releases/tag/v0.6.1

[0.7.0]: https://github.com/pboling/shiftable/releases/tag/v0.7.0
