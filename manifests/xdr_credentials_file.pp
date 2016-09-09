# == Define: aerospike::xdr_credentials_file
#
# We don't notify the service from here as if we change the credential in
# several files, the service would be restarted multiple times. The service is
# restarted only once after any change in the aerospike::config class.
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
