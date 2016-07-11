# == Class aerospike::config
#
# This class is called from the aerospike class to manage the configuration of
# your aerospike cluster.
#
class aerospike::config (
    $xdr_credentials = hiera_hash('aerospike::config::xdr_credentials', undef),
) {

  file { '/etc/aerospike/aerospike.conf':
    ensure  => file,
    content => template('aerospike/aerospike.conf.erb'),
    mode    => '0644',
    owner   => $aerospike::system_user,
    group   => $aerospike::system_group,
  }

  define xdr_credentials_file($all_xdr_credentials) {
      $dc_credentials = $all_xdr_credentials[$name]
      file { "/etc/aerospike/security-credentials_$name.txt":
        ensure  => file,
        content => template('aerospike/security-credentials.conf.erb'),
        mode    => '0600',
        owner   => $aerospike::system_user,
        group   => $aerospike::system_group,
      }
  }

  if $xdr_credentials {
    $xdr_rDCs = keys($xdr_credentials)
    xdr_credentials_file { $xdr_rDCs: all_xdr_credentials => $xdr_credentials }
  }

}
