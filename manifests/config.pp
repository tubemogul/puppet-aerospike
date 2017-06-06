# == Class aerospike::config
#
# This class is called from the aerospike class to manage the configuration of
# your aerospike cluster.
#
class aerospike::config {

  file { '/etc/aerospike/aerospike.conf':
    ensure  => file,
    content => template('aerospike/aerospike.conf.erb'),
    mode    => '0644',
    owner   => $aerospike::system_user,
    group   => $aerospike::system_group,
  }

  # If 'aerospike::config_xdr_credentials' defined - create file(s) with credentials for XDR
  if ! empty($aerospike::config_xdr_credentials) {
    $xdr_rdcs = keys($aerospike::config_xdr_credentials)
    aerospike::xdr_credentials_file {
      $xdr_rdcs:
        all_xdr_credentials => $aerospike::config_xdr_credentials,
        owner               => $aerospike::system_user,
        group               => $aerospike::system_group,
    }
  }
}
