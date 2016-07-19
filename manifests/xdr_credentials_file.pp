# == Define: aerospike::xdr_credentials_file
#
define aerospike::xdr_credentials_file (
  $all_xdr_credentials,
  $owner = 'root',
  $group = 'root',
) {
  if ! empty($all_xdr_credentials) {
    $dc_credentials = $all_xdr_credentials[$name]
    file { "/etc/aerospike/security-credentials_${name}.txt":
      ensure  => present,
      content => template('aerospike/security-credentials.conf.erb'),
      mode    => '0600',
      owner   => $owner,
      group   => $group,
    }
  }

}
