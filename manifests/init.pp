# == Class: aerospike
#
# Manage an aerospike installation, configuration and service.
# It can optionally install the amc console and manage the corresponding
# service.
#
# === Parameters
#
# [*version*]
#   Version of aerospike to install.
#
# [*download_dir*]
#   Directory where to download the archive becore unpacking it.
#
# [*download_url*]
#   URL from where to download the tarball. Only populate it if you want the
#   package to be downloaded from somewhere else than the aerospike website.
#   Note: It is mandatory to keep the name of the target file set to the
#   following pattern when using this custom url:
#   aerospike-server-${aerospike::edition}-${aerospike::version}-${aerospike::target_os_tag}.tgz
#
#   The default url is:
#   http://www.aerospike.com/artifacts/aerospike-server-${aerospike::edition}/${aerospike::version}/aerospike-server-${aerospike::edition}-${aerospike::version}-${aerospike::target_os_tag}.tgz
#
# [*remove_archive*]
#   Whether to remove the tarball once extracted for the aerospike server part.
#   Is also used for the amc when downloading a tarball (not for the deb
#   package)
#
# [*edition*]
#   The edition to use (enterprise or community)
#
# [*target_os_tag*]
#   Tag used in the target file name to identify the distribution package to use
#
# [*download_user*]
#   Username to use to download the enterprise version of the package. This is
#   used for both the download of the aerospike server package and the amc.
#
# [*download_pass*]
#   Password to use to download the enterprise version of the package to use
#   used for both the download of the aerospike server package and the amc.
#
# [*system_user*]
#   OS user where the service will be used in the service configuration
#   This user will only be defined if not already defined somewhere else in your
#   Puppet catalog
#
# [*system_uid*]
#   UID of the OS user to use
#
# [*system_group*]
#   OS group where the service will be used in the service configuration
#   This group will only be defined if not already defined somewhere else in your
#   Puppet catalog
#
# [*system_gid*]
#   GID of the OS user to use
#
# [*config_service*]
#   Configuration parameters to define in the service context of the aerospike
#   configuration file.
#   This parameter is a hash table with:
#     - the property name as key
#     - the property value as value
#   Note: The user and group are already defined by the system_user and
#         system_group parameters.
#
#   For more information, check the properties declared as in the "service"
#   context in http://www.aerospike.com/docs/reference/configuration/
#
# [*config_logging*]
#   Configuration parameters to define in the logging context of the aerospike
#   configuration file.
#   This parameter is a hash table with:
#       - the log file path as key (Log file must be an absolute path.)
#       - an array with the definition of all the contexts definitions as value
#
#   For more information about logging management in aerospike, check:
#   http://www.aerospike.com/docs/operations/configure/log/
#
# [*config_net_svc*]
#   Configuration parameters to define in the service sub-stanza in the network
#   context of the aerospike configuration file.
#   This parameter is a hash table with:
#     - the property name as key
#     - the property value as value
#
#   For more information about this sub-stanza:
#   http://www.aerospike.com/docs/operations/configure/network/general/
#
# [*config_net_fab*]
#   Configuration parameters to define in the fabric sub-stanza in the network
#   context of the aerospike configuration file.
#   This parameter is a hash table with:
#     - the property name as key
#     - the property value as value
#
#   For more information about this sub-stanza:
#   http://www.aerospike.com/docs/operations/configure/network/general/
#
# [*config_net_inf*]
#   Configuration parameters to define in the info sub-stanza in the network
#   context of the aerospike configuration file.
#   This parameter is a hash table with:
#     - the property name as key
#     - the property value as value
#
#   For more information about this sub-stanza:
#   http://www.aerospike.com/docs/operations/configure/network/general/
#
# [*config_net_hb*]
#   Configuration parameters to define in the heartbeat sub-stanza in the
#   network context of the aerospike configuration file.
#   This parameter is a hash table with:
#     - the property name as key
#     - the property value as value
#   IMPORTANT: for declaring mesh-seed-address-port, you will need to use the
#              'mesh-seed-address-port <IP Address>' as a key if you want it
#              to work.
#
#   For more information about the heartbeat sub-stanza:
#   http://www.aerospike.com/docs/operations/configure/network/heartbeat/
#
# [*config_ns*]
#   Configuration parameters to define the namespaces contexts in the aerospike
#   configuration file.
#   This parameter is a hash table with:
#     - the namespace name as key
#     - the value is another hash table composed by:
#       - the name of the property as key
#       - the value of the property as value.
#   When defining a sub-stanza in it for a property like you do for a
#   storage-engine device, you have to concatenante the property and the value
#   as the key (for example: "storage-engine device") and set the value as an
#   array, each item of the array being a line of configuration that you want to
#   have defined as-is in your sub-stanza. Check the example section of this
#   file for a more concrete example.
#
#  For more details on the properties you can define on the namespace context,
#  check: http://www.aerospike.com/docs/reference/configuration/ 
#
# [*config_cluster*]
#   Configuration parameters to define the cluster context in the aerospike
#   configuration file.
#   This parameter is a hash table with:
#     - the property name as key
#     - the property value as value
#
#   For more information on how to define a rack-aware cluster, see:
#   http://www.aerospike.com/docs/operations/configure/network/rack-aware/
#
# [*config_sec*]
#   Configuration parameters to define the security context in the aerospike
#   configuration file.
#   This parameter is a hash table with:
#     - the property name as key
#     - the value of the property as value.
#   Note: When defining a subcontext in it for a property like you do for the
#         syslog or log subcontexts, set the subcontext name as the key and the
#         value will be an array with each item of the array being a full line
#         of configuration.
#
# [*config_xdr*]
#   Configuration parameters to define the xdr context in the aerospike
#   configuration file (for cross-datacenter replication).
#   This parameter is a hash table with:
#     - the property name as key
#     - the value of the property as value.
#   Note: When defining a subcontext in it for a property like you do for the
#         datacenter subcontext, set the subcontext name as the key and the
#         value will be an array with each item of the array being a full line
#         of configuration.
#
#   For more informations about configuring xdr, check:
#   http://www.aerospike.com/docs/operations/configure/cross-datacenter/
#
# [*service_status*]
#   Controls the status of the service ("ensure" attribute in the puppet service
#   declaration).
#
# [*amc_install*]
#   If set to true, this will download and install the amc console package.
#
# [*amc_version*]
#   Sets which version of the amc package to install.
#
# [*amc_download_dir*]
#   Directory used to download the amc package.
#
# [*amc_download_url*]
#   URL from where to download the amc package. Only populate it if you want the
#   package to be downloaded from somewhere else than the aerospike website.
#   Note: It is mandatory to keep the name of the target file set to the
#   same pattern as the original name when using this custom url aka:
#   aerospike-amc-${aerospike::edition}-${amc_version}${amc_pkg_extension}
#
#   The default url is:
#   http://www.aerospike.com/artifacts/aerospike-amc-${aerospike::edition}/${amc_version}/aerospike-amc-${aerospike::edition}-${amc_version}${amc_pkg_extension}
#
# [*amc_manage_service*]
#   Boolean that defines if you want to control the amc service via puppet or
#   not.
#
# [*amc_service_status*]
#   Controls the status of the management console service ("ensure" attribute in
#   the puppet service declaration).
#
# === Examples
#
#  class { 'aerospike':
#    $config_ns = {
#      'bar'                  => {
#        'replication-factor' => 2,
#        'memory-size'        => '10G',
#        'default-ttl'        => '30d',
#        'storage-engine'     => 'memory',
#      },
#      'foo'                     => {
#        'replication-factor'    => 2,
#        'memory-size'           => '1G',
#        'storage-engine device' => [
#          'file /data/aerospike/foo.dat',
#          'filesize 10G',
#          'data-in-memory false',
#        ]
#      },
#    },
#    $config_sec                  => {
#      'privilege-refresh-period' => 500,
#      'syslog'                   => [
#        'local 0',
#        'report-user-admin true',
#        'report-authentication true',
#        'report-data-op foo true',
#      ],
#      'log'                   => [
#        'report-violation true',
#      ],
#    },
#    $config_xdr => {
#      'enable-xdr' => true,
#      'xdr-namedpipe-path' => '/tmp/xdr_pipe',
#      'xdr-digestlog-path' => '/opt/aerospike/digestlog 100G',
#      'xdr-errorlog-path' => '/var/log/aerospike/asxdr.log',
#      'xdr-pidfile' => '/var/run/aerospike/asxdr.pid',
#      'local-node-port' => 3000,
#      'xdr-info-port' => 3004,
#      'datacenter DC1' => [
#        'dc-node-address-port 172.68.17.123 3000',
#      ],
#      'datacenter DC2' => [
#        'dc-node-address-port 172.68.39.123 3000',
#      ],
#    },
#  }
#
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
  $config_cluster     = {},
  $config_sec         = {},
  $config_xdr         = {},
  $service_status     = 'running',
  $amc_install        = false,
  $amc_version        = '3.6.6',
  $amc_download_dir   = '/usr/local/src',
  $amc_download_url   = undef,
  $amc_manage_service = false,
  $amc_service_status = 'running',
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
  )
  if ! is_integer($system_uid) { fail("invalid ${system_uid} provided") }
  if ! is_integer($system_gid) { fail("invalid ${system_gid} provided") }

  class {'aerospike::install': } ->
  class {'aerospike::config': } ~>
  class {'aerospike::service': }
}
