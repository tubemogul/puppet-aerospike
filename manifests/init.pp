# == Class: aerospike
#
# Manage an aerospike installation, configuration and service.
# It can optionally install the amc console and manage the corresponding
# service.
#
# For the full documentation, please refer to:
# https://github.com/tubemogul/puppet-aerospike/blob/master/README.markdown
#
class aerospike (
  $version        = '3.7.2',
  $download_dir   = '/usr/local/src',
  $download_url   = undef,
  $remove_archive = false,
  $edition        = 'community',
  $target_os_tag  = 'ubuntu14.04',
  $download_user  = undef,
  $download_pass  = undef,
  $system_user    = 'root',
  $system_uid     = 0,
  $system_group   = 'root',
  $system_gid     = 0,
  $config_service = {
    'paxos-single-replica-limit'    => 1,
    'pidfile'                       => '/var/run/aerospike/asd.pid',
    'service-threads'               => 4,
    'transaction-queues'            => 4,
    'transaction-threads-per-queue' => 4,
    'proto-fd-max'                  => 15000,
  },
  $config_logging = {
    '/var/log/aerospike/aerospike.log' => [ 'any info', ],
  },
  $config_net_svc = {
    'address' => 'any',
    'port'    => 3000,
  },
  $config_net_fab = {
    'address' => 'any',
    'port'    => 3001,
  },
  $config_net_inf = {
    'address' => 'any',
    'port'    => 3003,
  },
  $config_net_hb  = {
    'mode'     => 'multicast',
    'address'  => 'any',
    'port'     => 9918,
    'interval' => 150,
    'timeout'  => 10,
  },
  $config_ns      = {
    'foo'                     => {
      'replication-factor'    => 2,
      'memory-size'           => '1G',
      'storage-engine device' => [
        'file /data/aerospike/data1.dat',
        'file /data/aerospike/data2.dat',
        'filesize 10G',
        'data-in-memory false',
      ]
    },
  },
  $config_cluster         = {},
  $config_sec             = {},
  $config_xdr             = {},
  $config_xdr_credentials = {},
  $service_status         = 'running',
  $amc_install            = false,
  $amc_version            = '3.6.6',
  $amc_download_dir       = '/usr/local/src',
  $amc_download_url       = undef,
  $amc_manage_service     = false,
  $amc_service_status     = 'running',
) {

  validate_string(
    $version,
    $download_dir,
    $edition,
    $target_os_tag,
    $system_user,
    $system_group,
    $service_status,
    $amc_version,
    $amc_download_dir,
    $amc_service_status,
  )
  validate_bool(
    $remove_archive,
    $amc_install,
    $amc_manage_service,
  )
  validate_hash(
    $config_service,
    $config_logging,
    $config_net_svc,
    $config_net_fab,
    $config_net_inf,
    $config_net_hb,
    $config_ns,
    $config_cluster,
    $config_sec,
    $config_xdr,
    $config_xdr_credentials,
  )
  if ! is_integer($system_uid) { fail("invalid ${system_uid} provided") }
  if ! is_integer($system_gid) { fail("invalid ${system_gid} provided") }

  # If 'config_xdr_credentials' defined - create file(s) with credentials for XDR
  if ! empty($config_xdr_credentials) {
    $xdr_rDCs = keys($config_xdr_credentials)
    aerospike::xdr_credentials_file {
      $xdr_rDCs:
        all_xdr_credentials => $config_xdr_credentials,
        owner               => $system_user,
        group               => $system_group,
    }
  }

  class {'aerospike::install': } ->
  class {'aerospike::config': } ~>
  class {'aerospike::service': }
}
