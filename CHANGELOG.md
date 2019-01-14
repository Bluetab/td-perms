# Changelog

## [2.11.2] 2019-01-14

### Added

- Allow a value to be associated with a nonce

## [2.11.0] 2019-01-11

### Added

- Added functionality to check permissions over all domains

## [2.10.1] 2019-01-11

### Added

- [TD-933] New cache for relations management

## [2.10.0] 2018-12-18

### Added

- Added manage_confidential_structures permission

## [2.8.1] 2018-11-15

### Changed

- BREAKING: Update Redix to 0.8.2 (use `:redis_host` in config instead of `:redis_uri`)
- Simplified taxonomy cache and user cache (use MULTI commands instead of multiple put methods)
- Added a SET for root domain ids

## [2.7.7] 2018-11-08

### Added

- Create user email cache, having the full_name as key

## [2.7.6] 2018-11-08

### Added

- Create user email cache, having the full_name as key

## [2.7.5] 2018-11-07

### Fixed

- Failure cleaning DF Cache

## [2.7.4] 2018-11-07

### Fixed

- Mock DF Cache delete functionality return correct format

## [2.7.3] 2018-11-07

### Changed

- Change Mock DF Cache to write only template fields

## [2.7.2] 2018-11-07

### Changed

- Add clean_cache feature on DF Cache
- Add Mock for DF Cache

## [2.7.1] 2018-10-31

### Changed

- Adds templates ID on DF Cache

## [2.7.0] 2018-10-31

### Fixed

- Failure loading acl cache when user list is empty
