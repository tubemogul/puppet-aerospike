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

}
