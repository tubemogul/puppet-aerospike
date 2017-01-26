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
  $version                  = '3.8.4',
  $download_dir             = '/usr/local/src',
  $download_url             = undef,
  $remove_archive           = false,
  $edition                  = 'community',
  $target_os_tag            = $::aerospike::params::target_os_tag,
  $download_user            = undef,
  $download_pass            = undef,
  $asinstall_params         = undef,
  $system_user              = 'root',
  $system_uid               = undef,
  $system_group             = 'root',
  $system_gid               = undef,
  $manage_service           = true,
  $restart_on_config_change = true,
  $config_service           = {
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
  $config_mod_lua = {},
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
      ],
    },
  },
  $config_cluster         = {},
  $config_sec             = {},
  $config_xdr             = {},
  $config_xdr_credentials = {},
  $service_status         = 'running',
  $service_enable         = true,
  $service_provider       = undef,
  $amc_install            = false,
  $amc_version            = '3.6.6',
  $amc_download_dir       = '/usr/local/src',
  $amc_download_url       = undef,
  $amc_manage_service     = false,
  $amc_service_status     = 'running',
  $amc_service_enable     = true,
) inherits ::aerospike::params {

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
    $amc_install,
    $amc_manage_service,
    $amc_service_enable,
    $manage_service,
    $remove_archive,
    $restart_on_config_change,
    $service_enable,
  )
  validate_hash(
    $config_service,
    $config_logging,
    $config_mod_lua,
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
  if $service_provider { validate_string($service_provider) }
  if $system_uid and ! is_integer($system_uid) { fail("invalid ${system_uid} provided") }
  if $system_gid and ! is_integer($system_gid) { fail("invalid ${system_gid} provided") }

  include '::aerospike::install'
  include '::aerospike::config'
  include '::aerospike::service'

  if $manage_service and $restart_on_config_change {
    Class['aerospike::config'] ~>
    Class['aerospike::service']
  }

  Class['aerospike::install'] ->
  Class['aerospike::config'] ->
  Class['aerospike::service']

}
