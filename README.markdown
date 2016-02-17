# Aerospike Puppet module

[![TravisBuild](https://travis-ci.org/tubemogul/puppet-aerospike.svg?branch=master)](https://travis-ci.org/tubemogul/puppet-aerospike)
[![Puppet Forge latest release](https://img.shields.io/puppetforge/v/TubeMogul/aerospike.svg)](https://forge.puppetlabs.com/TubeMogul/aerospike)
[![Puppet Forge downloads](https://img.shields.io/puppetforge/dt/TubeMogul/aerospike.svg)](https://forge.puppetlabs.com/TubeMogul/aerospike)
[![Puppet Forge score](https://img.shields.io/puppetforge/f/TubeMogul/aerospike.svg)](https://forge.puppetlabs.com/TubeMogul/aerospike/scores)

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with aerospike](#setup)
    * [What aerospike affects](#what-aerospike-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with aerospike](#beginning-with-aerospike)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

This module installs the [aerospike](www.aerospike.com) package repository manager and configures it.
It can optionally install the amc console and manage the corresponding service.

It has been tested and used in production with:

 * Puppet 3.8 on Ubuntu 14.04 (trusty)

The spec tests pass against puppet >= 3.2 including the future parser.

##Module Description

What is this module capable of doing?

 * Download and install the aerospike database package in a specific version
 * Optionally download and install the aerospike management console package in a specific version
 * Manage a specific user and group (with their corresponding fixed uid/gid) dedicated to the service
 * Manage all the contexts configurable in an aerospike server installation
 * Manage the aerospike server service
 * Optionnally manage the aerospike management console service

##Setup

###What aerospike affects

Files managed by the module:

* /etc/aerospike/aerospike.conf

###Setup Requirements

The module requires:
 - [Puppetlabs stdlib](https://github.com/puppetlabs/puppetlabs-stdlib.git)
 - [Puppet-community's archive module](https://github.com/puppet-community/puppet-archive.git) tested against version 0.4.4

###Beginning with aerospike

The module can be used out of the box directly, it just requires puppet-community's archive module and puppetlab's stdlib to be in your modulepath.

To install (with all the dependencies):

```
puppet module install puppetlabs/stdlib
puppet module install puppet/archive
puppet module install TubeMogul/aerospike
```

##Usage

Declaring 2 namespaces 'bar' (stored in memory) and 'foo' (store in a file).

```puppet
class { 'aerospike':
  $config_ns = {
    'bar'                  => {
      'replication-factor' => 2,
      'memory-size'        => '10G',
      'default-ttl'        => '30d',
      'storage-engine'     => 'memory',
    },
    'foo'                     => {
      'replication-factor'    => 2,
      'memory-size'           => '1G',
      'storage-engine device' => [
        'file /data/aerospike/foo.dat',
        'filesize 10G',
        'data-in-memory false',
      ]
    },
  },
}
```

##Parameters reference

###class aerospike

 * `version`: Version of aerospike to install. (default: 3.7.2)

 * `download_dir`: Directory where to download the archive becore unpacking it.
   (default: /usr/local/src)

 * `download_url`:
  URL from where to download the tarball. Only populate it if you want the
  package to be downloaded from somewhere else than the aerospike website.
  Note: It is mandatory to keep the name of the target file set to the
  following pattern when using this custom url:
  aerospike-server-${aerospike::edition}-${aerospike::version}-${aerospike::target_os_tag}.tgz
  (default: http://www.aerospike.com/artifacts/aerospike-server-${aerospike::edition}/${aerospike::version}/aerospike-server-${aerospike::edition}-${aerospike::version}-${aerospike::target_os_tag}.tgz)

 * `remove_archive`:
  Whether to remove the tarball once extracted for the aerospike server part.
  Is also used for the amc when downloading a tarball (not for the deb
  package) (default: false)

 * `edition`: The edition to use (enterprise or community - default: community)

 * `target_os_tag`:
  Tag used in the target file name to identify the distribution package to use
  (default: ubuntu14.04)

 * `download_user`:
  Username to use to download the enterprise version of the package. This is
  used for both the download of the aerospike server package and the amc.
  (default: undef)

 * `download_pass`:
  Password to use to download the enterprise version of the package to use
  used for both the download of the aerospike server package and the amc.
  (default: undef)

 * `system_user`:
  OS user where the service will be used in the service configuration
  This user will only be defined if not already defined somewhere else in your
  Puppet catalog. (default: root)

 * `system_uid`: UID of the OS user to use. (default: 0)

 * `system_group`:
  OS group where the service will be used in the service configuration
  This group will only be defined if not already defined somewhere else in your
  Puppet catalog. (default: root)

 * `system_gid`: GID of the OS user to use. (default: 0)

 * `config_service`:
  Configuration parameters to define in the service context of the aerospike
  configuration file.
  This parameter is a hash table with:
    - the property name as key
    - the property value as value
  Note: The user and group are already defined by the system_user and
        system_group parameters.

  The default configuration generates the following configuration for the
  service context:
  ```
  service {
    user root
    group root
    paxos-single-replica-limit 1
    pidfile /var/run/aerospike/asd.pid
    proto-fd-max 15000
    service-threads 4
    transaction-queues 4
    transaction-threads-per-queue 4
  }
  ```

  For more information, check the properties declared as in the "service"
  context in http://www.aerospike.com/docs/reference/configuration/

 * `config_logging`:
  Configuration parameters to define in the logging context of the aerospike
  configuration file.
  This parameter is a hash table with:
      - the log file path as key (Log file must be an absolute path.)
      - an array with the definition of all the contexts definitions as value

  The default configuration generates the following configuration for the
  logging context:
  ```
  logging {
    file /var/log/aerospike/aerospike.log {
      context any info
    }
  }
  ```

  For more information about logging management in aerospike, check:
  http://www.aerospike.com/docs/operations/configure/log/

 * `config_net_svc`:
  Configuration parameters to define in the service sub-stanza in the network
  context of the aerospike configuration file.
  This parameter is a hash table with:
    - the property name as key
    - the property value as value

  For more information about this sub-stanza:
  http://www.aerospike.com/docs/operations/configure/network/general/

 * `config_net_fab`:
  Configuration parameters to define in the fabric sub-stanza in the network
  context of the aerospike configuration file.
  This parameter is a hash table with:
    - the property name as key
    - the property value as value

  For more information about this sub-stanza:
  http://www.aerospike.com/docs/operations/configure/network/general/

 * `config_net_inf`:
  Configuration parameters to define in the info sub-stanza in the network
  context of the aerospike configuration file.
  This parameter is a hash table with:
    - the property name as key
    - the property value as value

  For more information about this sub-stanza:
  http://www.aerospike.com/docs/operations/configure/network/general/

 * `config_net_hb`:
  Configuration parameters to define in the heartbeat sub-stanza in the
  network context of the aerospike configuration file.
  This parameter is a hash table with:
    - the property name as key
    - the property value as value
  IMPORTANT: for declaring mesh-seed-address-port, you will need to use the
             'mesh-seed-address-port <IP Address>' as a key if you want it
             to work.

  For more information about the heartbeat sub-stanza:
  http://www.aerospike.com/docs/operations/configure/network/heartbeat/

 * `config_ns`:
  Configuration parameters to define the namespaces contexts in the aerospike
  configuration file.
  This parameter is a hash table with:
    - the namespace name as key
    - the value is another hash table composed by:
      - the name of the property as key
      - the value of the property as value.
  When defining a sub-stanza in it for a property like you do for a
  storage-engine device, you have to concatenante the property and the value
  as the key (for example: "storage-engine device") and set the value as an
  array, each item of the array being a line of configuration that you want to
  have defined as-is in your sub-stanza. Check the example section of this
  file for a more concrete example.

  For more details on the properties you can define on the namespace context,
  check: http://www.aerospike.com/docs/reference/configuration/

 * `config_cluster`:
  Configuration parameters to define the cluster context in the aerospike
  configuration file.
  This parameter is a hash table with:
    - the property name as key
    - the property value as value

  For more information on how to define a rack-aware cluster, see:
  http://www.aerospike.com/docs/operations/configure/network/rack-aware/

 * `config_sec`:
  Configuration parameters to define the security context in the aerospike
  configuration file.
  This parameter is a hash table with:
    - the property name as key
    - the value of the property as value.
  Note: When defining a subcontext in it for a property like you do for the
        syslog or log subcontexts, set the subcontext name as the key and the
        value will be an array with each item of the array being a full line
        of configuration.

 * `config_xdr`:
  Configuration parameters to define the xdr context in the aerospike
  configuration file (for cross-datacenter replication).
  This parameter is a hash table with:
    - the property name as key
    - the value of the property as value.
  Note: When defining a subcontext in it for a property like you do for the
        datacenter subcontext, set the subcontext name as the key and the
        value will be an array with each item of the array being a full line
        of configuration.

  For more informations about configuring xdr, check:
  http://www.aerospike.com/docs/operations/configure/cross-datacenter/

 * `service_status`:
  Controls the status of the service ("ensure" attribute in the puppet service
  declaration - default: running).

 * `amc_install`: If set to true, this will download and install the amc console package. (default: false)

 * `amc_version`: Sets which version of the amc package to install. (default: 3.6.6)

 * `amc_download_dir`: Directory used to download the amc package. (default: /usr/local/src)

 * `amc_download_url`:
  URL from which to download the amc package. Only populate it if you want the
  package to be downloaded from somewhere else than the aerospike website.
  Note: It is mandatory to keep the name of the target file set to the
  same pattern as the original name when using this custom url aka:
  aerospike-amc-${aerospike::edition}-${amc_version}${amc_pkg_extension}

  The default url is:
  http://www.aerospike.com/artifacts/aerospike-amc-${aerospike::edition}/${amc_version}/aerospike-amc-${aerospike::edition}-${amc_version}${amc_pkg_extension}

 * `amc_manage_service`:
  Boolean that defines if you want to control the amc service via puppet or
  not. (default: false)

 * `amc_service_status`:
  Controls the status of the management console service ("ensure" attribute in
  the puppet service declaration - default: running).

The default parameters generate the following aerospike configuration file:
```
# Aerospike database configuration file.

# service context definition
service {
  user root
  group root
  paxos-single-replica-limit 1
  pidfile /var/run/aerospike/asd.pid
  proto-fd-max 15000
  service-threads 4
  transaction-queues 4
  transaction-threads-per-queue 4
}

# logging context definition
logging {
  file /var/log/aerospike/aerospike.log {
    context any info
  }
}

# network context definition
network {
  service {
  address any
  port 3000
  }

  fabric {
  address any
  port 3001
  }

  info {
  address any
  port 3003
  }

  heartbeat {
  interval 150
  mode multicast
  port 9918
  timeout 10
  }
}

namespace foo {
  memory-size 1G
  replication-factor 2
  storage-engine device {
    data-in-memory false
    file /data/aerospike/data1.dat
    file /data/aerospike/data2.dat
    filesize 10G
  }
}
```

Example of an aerospike installation with 2 namespaces and a replication to 2
datacenters and a configuration of a security context:
```
class { 'aerospike':
  $config_ns = {
    'bar'                  => {
      'replication-factor' => 2,
      'memory-size'        => '10G',
      'default-ttl'        => '30d',
      'storage-engine'     => 'memory',
    },
    'foo'                     => {
      'replication-factor'    => 2,
      'memory-size'           => '1G',
      'storage-engine device' => [
        'file /data/aerospike/foo.dat',
        'filesize 10G',
        'data-in-memory false',
      ]
    },
  },
  $config_sec                  => {
    'privilege-refresh-period' => 500,
    'syslog'                   => [
      'local 0',
      'report-user-admin true',
      'report-authentication true',
      'report-data-op foo true',
    ],
    'log'                   => [
      'report-violation true',
    ],
  },
  $config_xdr => {
    'enable-xdr' => true,
    'xdr-namedpipe-path' => '/tmp/xdr_pipe',
    'xdr-digestlog-path' => '/opt/aerospike/digestlog 100G',
    'xdr-errorlog-path' => '/var/log/aerospike/asxdr.log',
    'xdr-pidfile' => '/var/run/aerospike/asxdr.pid',
    'local-node-port' => 3000,
    'xdr-info-port' => 3004,
    'datacenter DC1' => [
      'dc-node-address-port 172.68.17.123 3000',
    ],
    'datacenter DC2' => [
      'dc-node-address-port 172.68.39.123 3000',
    ],
  },
}
```

##Limitations

This module has only been tested against Ubuntu 14.04, but it should work with
the Debian family and the Red Hat servers.

##Development

See the CONTRIBUTING.md file.

