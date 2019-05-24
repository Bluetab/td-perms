# Changelog

## [2.20.1] 2019-05-24

## Added 

- [TD-1535] Function to query a permission from an ingest resource 

## [2.20.0] 2019-05-24

## Added 

- [TD-1535] Permission manage_ingest_relations

## [2.19.1] 2019-05-15

### Fixed

- BusinessConceptCache backwards compatibility issue introduced in 2.19.0

## [2.19.0] 2019-05-08

### Added

- Temporary methods for storing deprecated parent_id of business_concepts

## [2.16.3] 2019-04-23

### Added

- Mock for business_concept cache

## [2.16.2] 2019-04-23

### Added

- Function to delete an user from an acl

## [2.16.1] 2019-04-09

### Changed

- RelationCache will delete record of untagged relations

## [2.16.0] 2019-03-28

### Changed

- RelationCache will create record of untagged relations

## [2.15.0] 2019-03-10

### Added

- Functionality for listing templates by scope

### Removed

- Removed obsolete functionality for default templates

## [2.14.0] 2019-02-21

### Added

- [TD-1422] When a BC is deleted, all their relations are deleted too.
    
## [2.12.1] 2019-02-01

### Added

- [TD-967] Contextual information will be stored when a relation in persisted on cache.
    - The information will be persisted for both, the target and source of a relation.

## [2.12.0] 2019-01-28

### Added

- [TD-1390] New sets in business concepts' cache to store the ids of the existing and deprecated business concepts

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
