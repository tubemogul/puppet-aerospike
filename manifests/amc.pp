# == Class: aerospike::amc
#
# This class is called from the aerospike class to download and install an
# Aerospike Management Console
#
# == Dependencies
#
# The archive module available at:
# https://forge.puppetlabs.com/puppet/archive
#
class aerospike::amc {

  include '::archive'

  # On the amc, some elements are changing depending on the os familly
  case $::osfamily {
    'Debian': {
      $amc_pkg_extension = '_amd64.deb'
      $amc_pkg_provider = 'dpkg'
      $amc_pkg_name="aerospike-amc-${aerospike::edition}-${aerospike::amc_version}${amc_pkg_extension}"
      $amc_extract = false
      $amc_target_archive = "${aerospike::amc_download_dir}/${amc_pkg_name}"
      $amc_dest = $amc_target_archive
    }
    'RedHat': {
      $amc_pkg_extension = '.x86_64.rpm'
      $amc_pkg_provider = 'rpm'
      $amc_pkg_name="aerospike-amc-${aerospike::edition}-${aerospike::amc_version}${amc_pkg_extension}"
      $amc_extract = false
      $amc_target_archive = "${aerospike::amc_download_dir}/${amc_pkg_name}"
      $amc_dest = $amc_target_archive
    }
    default: {
      $amc_pkg_extension ='-linux.tar.gz'
      $amc_pkg_name="aerospike-amc-${aerospike::edition}-${aerospike::amc_version}${amc_pkg_extension}"
      $amc_pkg_provider = undef
      $amc_extract = true
      $amc_target_archive = "${aerospike::amc_download_dir}/${amc_pkg_name}"
      $amc_dest = "${aerospike::amc_download_dir}/aerospike-amc-${aerospike::edition}-${aerospike::amc_version}"
    }
  }

  $amc_src = $aerospike::amc_download_url ? {
    undef => "http://www.aerospike.com/artifacts/aerospike-amc-${aerospike::edition}/${aerospike::amc_version}/aerospike-amc-${aerospike::edition}-${aerospike::amc_version}${amc_pkg_extension}",
    default => $aerospike::amc_download_url,
  }

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
