# == Class aerospike::service
#
# This class is called from the aerospike class to manage the status of the
# aerospike service on your servers.
#
class aerospike::service {

  if $aerospike::manage_service {
    service {'aerospike':
      ensure     => $aerospike::service_status,
      enable     => $aerospike::service_enable,
      hasrestart => true,
      hasstatus  => true,
      provider   => $aerospike::service_provider,
    }
  }

  if $aerospike::amc_manage_service {
    service {'amc':
      ensure     => $aerospike::amc_service_status,
      enable     => $aerospike::amc_service_enable,
      hasrestart => true,
      hasstatus  => true,
      provider   => $aerospike::service_provider,
    }
  }
}
