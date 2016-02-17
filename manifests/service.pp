# == Class aerospike::service
#
# This class is called from the aerospike class to manage the status of the
# aerospike service on your servers.
#
class aerospike::service {

  service {'aerospike':
    ensure     => $aerospike::service_status,
    hasrestart => true,
    hasstatus  => true,
    provider   => 'init',
  }

  if $aerospike::amc_manage_service {
    service {'amc':
      ensure     => $aerospike::amc_service_status,
      hasrestart => true,
      hasstatus  => true,
      provider   => 'init',
    }
  }
}
