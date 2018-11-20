# == Class: aerospike::install
#
# This class is called from the aerospike class to download and install an
# aerospike server
#
# == Dependencies
#
# The archive module available at:
# https://forge.puppetlabs.com/puppet/archive
#
class aerospike::install {

  include '::archive'

  # #######################################
  # Installation of aerospike server
  # #######################################
  $src = $aerospike::download_url ? {
    undef   => "http://www.aerospike.com/artifacts/aerospike-server-${aerospike::edition}/${aerospike::version}/aerospike-server-${aerospike::edition}-${aerospike::version}-${aerospike::target_os_tag}.tgz",
    default => $aerospike::download_url,
  }
  $dest = "${aerospike::download_dir}/aerospike-server-${aerospike::edition}-${aerospike::version}-${aerospike::target_os_tag}"

  if $aerospike::asinstall_params {
    $_asinstall_params = $aerospike::asinstall_params
  } else {
    $_asinstall_params = $::osfamily ? {
      'Debian' => '--force-confold -i',
      'RedHat' => '-Uvh',
      default  => '',
    }
  }

  archive { "${dest}.tgz":
    ensure       => present,
    source       => $src,
    username     => $aerospike::download_user,
    password     => $aerospike::download_pass,
    extract      => true,
    extract_path => $aerospike::download_dir,
    creates      => $dest,
    cleanup      => $aerospike::remove_archive,
  } ~> exec { 'aerospike-install-server':
    command     => "${dest}/asinstall ${_asinstall_params}",
    cwd         => $dest,
    refreshonly => true,
  }


  # #######################################
  # Defining the system user and group the service will be configured on
  # #######################################
  ensure_resource( 'user', $aerospike::system_user, {
      ensure  => present,
      uid     => $aerospike::system_uid,
      gid     => $aerospike::system_group,
      shell   => '/bin/bash',
      require => Group[$aerospike::system_group],
    }
  )

  ensure_resource('group', $aerospike::system_group, {
      ensure => present,
      gid    => $aerospike::system_gid,
    }
  )
}
