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
  } ~>
  exec { 'aerospike-install-server':
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

  # #######################################
  # Installation of the management console
  # Only if asked for it.
  # #######################################
  if $aerospike::amc_install {

    # On the amc, some elements are changing depending on the os familly
    case $::osfamily {
      'Debian': {
        $amc_pkg_extension = '.all.x86_64.deb'
        $amc_pkg_provider = 'dpkg'
        $amc_pkg_name="aerospike-amc-${aerospike::edition}-${aerospike::amc_version}${amc_pkg_extension}"
        $amc_extract = false
        $amc_target_archive = "${aerospike::amc_download_dir}/${amc_pkg_name}"
        $amc_dest = $amc_target_archive
        $bcrypt_os_packages  = ['build-essential', 'python-dev', 'libffi-dev']
      }
      'RedHat': {
        $amc_pkg_extension = "-${aerospike::target_os_tag}.x86_64.rpm"
        $amc_pkg_provider = 'rpm'
        $amc_pkg_name="aerospike-amc-${aerospike::edition}-${aerospike::amc_version}${amc_pkg_extension}"
        $amc_extract = false
        $amc_target_archive = "${aerospike::amc_download_dir}/${amc_pkg_name}"
        $amc_dest = $amc_target_archive
        $bcrypt_os_packages  = ['gcc', 'libffi-devel', 'python-devel']
      }
      default : {
        $amc_pkg_extension ='.tar.gz'
        $amc_pkg_name="aerospike-amc-${aerospike::edition}-${aerospike::amc_version}${amc_pkg_extension}"
        $amc_pkg_provider = undef
        $amc_extract = true
        $amc_target_archive = "${aerospike::amc_download_dir}/${amc_pkg_name}"
        $amc_dest = "${aerospike::amc_download_dir}/aerospike-amc-${aerospike::edition}-${aerospike::amc_version}"
        $bcrypt_os_packages  = ['gcc', 'libffi-devel', 'python-devel']
      }
    }


    $amc_src = $aerospike::amc_download_url ? {
      undef => "http://www.aerospike.com/artifacts/aerospike-amc-${aerospike::edition}/${aerospike::amc_version}/aerospike-amc-${aerospike::edition}-${aerospike::amc_version}${amc_pkg_extension}",
      default => $aerospike::amc_download_url,
    }

    $os_packages  = ['python-pip', 'ansible', 'python-paramiko']
    $pip_packages = ['markupsafe', 'ecdsa', 'pycrypto']
    ensure_packages($os_packages, { ensure => installed, } )
    ensure_packages($pip_packages, {
      ensure   => installed,
      provider => 'pip',
      require  => [ Package['python-pip'], ],
    })
    ensure_packages($bcrypt_os_packages, { ensure => installed, } )
    ensure_packages('bcrypt', {
      ensure   => installed,
      provider => 'pip',
      require  => [ Package[$bcrypt_os_packages], Package['python-pip'], ],
    })
    archive { $amc_target_archive:
      ensure       => present,
      source       => $amc_src,
      username     => $aerospike::download_user,
      password     => $aerospike::download_pass,
      extract      => $amc_extract,
      extract_path => $aerospike::amc_download_dir,
      creates      => $amc_dest,
      cleanup      => $aerospike::remove_archive,

    }

    # For now only the packages that are not tarballs are installed.
    if $amc_pkg_provider != undef {
      ensure_packages("aerospike-amc-${aerospike::edition}", {
        ensure   => latest,
        provider => $amc_pkg_provider,
        source   => $amc_dest,
        require  => [ Archive[$amc_target_archive], ],
      })
    } else {
      fail('Installation of the amc via tarball not yet supported by this module.')
    }
  }
}
