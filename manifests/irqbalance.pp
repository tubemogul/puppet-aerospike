# == Class aerospike::irqbalance
#
# This class is called from the aerospike class to manage the irqbalance for
# your aerospike cluster.
#
class aerospike::irqbalance {

  if $aerospike::disable_network_irqbalance {
    file { '/etc/default/irqbalance':
      ensure  => file,
      content => "IRQBALANCE_ARGS=\"--policyscript=/etc/aerospike/irqbalance-ban.sh\"\n",
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      notify  => Service['irqbalance'],
    }

    service { 'irqbalance':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
    }
  }

}
