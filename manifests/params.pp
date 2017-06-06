# == Class aerospike::params
#
# This class is used for determining distribution-specific configurations. All values
# can be manually overridden in main module's class `init.pp` by passing appropriate
# parameter.
#
class aerospike::params {

  # Select appropriate package for supported distribution.
  # See http://www.aerospike.com/download/
  case $::osfamily {
    # TODO: at some point we should replace flat facts by hierarchical
    # e.g. $::os[release][major] instead of $::operatingsystemmajrelease
    'Debian': {
      case $::operatingsystem {
        'Debian': {
          case $::operatingsystemmajrelease {
            '7': { $target_os_tag = 'debian7' }
            '8': { $target_os_tag = 'debian8' }
            default: { $target_os_tag = 'debian8' }
          }
        }
        'Ubuntu': {
          case $::operatingsystemmajrelease {
            '12.04': { $target_os_tag = 'ubuntu12.04' }
            '14.04': { $target_os_tag = 'ubuntu14.04' }
            '16.04': { $target_os_tag = 'ubuntu16.04' }
            default: { $target_os_tag = 'ubuntu16.04' }
          }
        }
        default: { $target_os_tag = 'debian8' }
      }
    }
    'Redhat': {
      case $::operatingsystemmajrelease {
        '6': { $target_os_tag = 'el6' }
        '7': { $target_os_tag = 'el7' }
        default: { $target_os_tag = 'el7' }
      }

    }
    default: {
      $target_os_tag = undef
    }
  }

}