# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.3.0] - 2017-01-30
### Added
- New parameter: `asinstall_params`: sets extra parameters to the installer
- New parameter: `service_provider`: sets which provider to use for the service
- New parameter: `service_enable`: enable or disable the aerospike service
- New parameter: `amc_service_enable`: enable or disable the amc service
- The `mod-lua` section has been added in the configuration
- Travis jobs for rubocop testing
- Adding missing `stdlib` dependency to the `metadata.json`
- A `aerospike::params` class has been added to hold the default values
- Update `.gitignore` to ignore all version-dependent files
- Adding the support for the RedHat OS family in the `metadata.json`

### Changed
- The default values of `system_uid` and `system_gid` have been changed from 0
  to undef to avoid resource duplications if the User[root] is already declared
  somewhere else
- Change `target_os_tag` to automatically pick the right one based on the OS
  family (extending the OS family to RedHat)
- Updating the `Gemfile`, `Rakefile` and `spec_helper.rb` based on the
  modulesync and puppet-module-skeleton
- Change of the travis test matrix to get quicker testing process
- `CHANGELOG` moved to `CHANGELOG.md` and using keepachangelog.com amd semver

### Fixed
- Massive code quality cleanup based on rubocop and rubocop-spec standards
- Fixed some puppet-lint warnings
- Fixed a typo on the shared tests for the AMC, making the AMC-specific tests
  not being called after the switch to shared examples
- Forcing the installation of asinstall to explicitly be non-interactive
- Fix filenames for RedHat OS family

### Dropped
- Removed the `TODO` file as we switch to github issues for listing the taks
- Removed the `CONTRIBUTORS` file. You can get the contributors via the GitHub API

## [1.2.1] - 2016-09-13
### Fixed
- Fix incorrect configuration generation when using multiple XDR targets for a namespace

## [1.2.0] - 2016-09-09
### Added
- Adding ways to not manage the service and not restart on config change
- Add examples in the documentation

### Fixed
- Fixing documentation examples
- Fixing Json_pure dependency problems in the gemfile for the puppet-spec tests
- Fixing declaration of multi-datacenter replication inside namespaces
- The puppet/archive module has been test to work n version ~> 1.0

## [1.1.2] - 2016-07-27
### Fixed
- added fix on AMC upgrade and dependencies

## [1.1.1] - 2016-07-19
### Added
- Addded notify to refresh service after creating/modifying XDR credential file
- Added tests for puppet 4.4 and 4.5

### Fixed
- Fixed a puppet-lint warning

## [1.1.0] - 2016-07-18
### Added
- Adding support for credential files on XDR

## [1.0.1] - 2016-03-02
### Fixed
- Fixing documentation issues
- Fixing metadata quality

## [1.0.0] - 2016-02-17
### Added
- Initial version of the module
