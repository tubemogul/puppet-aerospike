require 'spec_helper'

describe 'aerospike' do
  shared_examples 'supported_os' do |osfamily, dist, majrelease, expected_tag|
    # #####################################################################
    # Basic compilation test with all parameters to default
    # #####################################################################
    describe "aerospike class without any parameters on #{osfamily}, #{dist} #{majrelease}" do
      let(:params) { {} }
      let(:facts) do
        {
          osfamily: osfamily,
          operatingsystem: dist,
          operatingsystemmajrelease: majrelease
        }
      end

      it { is_expected.to compile.with_all_deps }

      # Tests related to the aerospike base class content
      it { is_expected.to create_class('aerospike') }
      it { is_expected.to contain_class('aerospike::install').that_comes_before('Class[aerospike::config]') }
      it { is_expected.to contain_class('aerospike::config') }
      it { is_expected.to contain_class('aerospike::service').that_subscribes_to('Class[aerospike::config]') }

      # Tests related to the aerospike::install class
      it { is_expected.to contain_class('archive') }
      it { is_expected.to contain_archive("/usr/local/src/aerospike-server-community-3.8.4-#{expected_tag}.tgz") }
      it { is_expected.to contain_exec('aerospike-install-server') }
      it { is_expected.to contain_user('root') }
      it { is_expected.to contain_group('root') }

      # Tests related to the aerospike::config class
      it do
        is_expected.to create_file('/etc/aerospike/aerospike.conf').\
          without_content(%r{^\s*cluster \{$}).\
          without_content(%r{^\s*security \{$}).\
          without_content(%r{^\s*xdr \{$})
      end

      # Tests related to the aerospike::service class
      it { is_expected.to contain_service('aerospike').with_ensure('running') }
    end

    # #####################################################################
    # Tests with just custom urls (specific case)
    # #####################################################################
    describe "aerospike class with custom url on #{osfamily}" do
      let(:params) do
        {
          version: '3.8.3',
          download_url: "http://my_fileserver.example.com/aerospike/aerospike-server-enterprise-3.8.3-#{expected_tag}.tgz",
          edition: 'enterprise'
        }
      end
      let(:facts) do
        {
          osfamily: osfamily,
          operatingsystem: dist,
          operatingsystemmajrelease: majrelease
        }
      end
      let(:target_dir) { "/usr/local/src/aerospike-server-enterprise-3.8.3-#{expected_tag}" }

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_archive("/usr/local/src/aerospike-server-enterprise-3.8.3-#{expected_tag}.tgz").\
          with_ensure('present').\
          with_source("http://my_fileserver.example.com/aerospike/aerospike-server-enterprise-3.8.3-#{expected_tag}.tgz").\
          with_extract(true).\
          with_extract_path('/usr/local/src').\
          with_creates(target_dir).\
          with_cleanup(false).\
          that_notifies('Exec[aerospike-install-server]')
      end

      case osfamily
      when 'Debian'
        it { is_expected.to contain_exec('aerospike-install-server').with_command("#{target_dir}/asinstall --force-confold -i") }
      when 'RedHat'
        it { is_expected.to contain_exec('aerospike-install-server').with_command("#{target_dir}/asinstall -Uvh") }
      end
    end

    # #####################################################################
    # Test with every parameter (except the custom urls covered earlier)
    # #####################################################################
    describe "aerospike class with all parameters (except custom url) on #{osfamily}, #{majrelease}" do
      let(:params) do
        {
          version: '3.8.3',
          download_dir: '/tmp',
          remove_archive:   true,
          edition:          'enterprise',
          download_user:    'dummy_user',
          download_pass:    'dummy_password',
          system_user:      'as_user',
          system_uid:       511,
          system_group:     'as_group',
          system_gid:       512,
          service_provider: 'init',
          config_service: {
            'paxos-single-replica-limit'    => 2,
            'pidfile'                       => '/run/aerospike/asd.pid',
            'service-threads'               => 8,
            'scan-thread'                   => 6,
            'transaction-queues'            => 2,
            'transaction-threads-per-queue' => 4,
            'proto-fd-max'                  => 20_000
          },
          config_logging: {
            '/var/log/aerospike/aerospike.log' => ['any info'],
            '/var/log/aerospike/aerospike.debug' => ['cluster debug', 'migrate debug']
          },
          config_net_svc: {
            'address'        => 'any',
            'port'           => 4000,
            'access-address' => '192.168.1.100'
          },
          config_net_fab: {
            'address' => 'any',
            'port'    => 4001
          },
          config_net_inf: {
            'address' => 'any',
            'port'    => 4003
          },
          config_net_hb: {
            'mode'                                 => 'mesh',
            'address'                              => '192.168.1.100',
            'mesh-seed-address-port 192.168.1.100' => '3002',
            'mesh-seed-address-port 192.168.1.101' => '3002',
            'mesh-seed-address-port 192.168.1.102' => '3002',
            'port'                                 => 3002,
            'interval'                             => 150,
            'timeout'                              => 10
          },
          config_ns: {
            'bar'                  => {
              'replication-factor' => 2,
              'memory-size'        => '10G',
              'default-ttl'        => '30d',
              'storage-engine'     => 'memory'
            },
            'foo'                     => {
              'replication-factor'    => 2,
              'memory-size'           => '1G',
              'storage-engine device' => [
                'file /data/aerospike/foo.dat',
                'filesize 10G',
                'data-in-memory false'
              ]
            }
          },
          config_cluster: {
            'mode' => 'dynamic',
            'self-group-id' => 201
          },
          config_sec: {
            'privilege-refresh-period' => 500,
            'syslog'                   => [
              'local 0',
              'report-user-admin true',
              'report-authentication true',
              'report-data-op foo true'
            ],
            'log' => [
              'report-violation true'
            ]
          },
          config_xdr: {
            'enable-xdr'         => true,
            'xdr-namedpipe-path' => '/tmp/xdr_pipe',
            'xdr-digestlog-path' => '/opt/aerospike/digestlog 100G',
            'xdr-errorlog-path'  => '/var/log/aerospike/asxdr.log',
            'xdr-pidfile'        => '/var/run/aerospike/asxdr.pid',
            'local-node-port'    => 4000,
            'xdr-info-port'      => 3004,
            'datacenter DC1'     => [
              'dc-node-address-port 172.68.17.123 3000'
            ]
          },
          config_mod_lua: {
            'user-path' => '/opt/aerospike/usr/udf/lua'
          },
          service_status: 'stopped'
        }
      end
      let(:facts) do
        {
          osfamily: osfamily,
          operatingsystem: dist,
          operatingsystemmajrelease: majrelease
        }
      end

      let(:target_dir) { "/tmp/aerospike-server-enterprise-3.8.3-#{expected_tag}" }

      it { is_expected.to compile.with_all_deps }

      # Tests related to the aerospike base class content
      it { is_expected.to create_class('aerospike') }
      it { is_expected.to contain_class('aerospike::install').that_comes_before('Class[aerospike::config]') }
      it { is_expected.to contain_class('aerospike::config') }
      it { is_expected.to contain_class('aerospike::service').that_subscribes_to('Class[aerospike::config]') }

      # Tests related to the aerospike::install class
      it do
        is_expected.to contain_archive("/tmp/aerospike-server-enterprise-3.8.3-#{expected_tag}.tgz").\
          with_ensure('present').\
          with_source("http://www.aerospike.com/artifacts/aerospike-server-enterprise/3.8.3/aerospike-server-enterprise-3.8.3-#{expected_tag}.tgz").\
          with_username('dummy_user').\
          with_password('dummy_password').\
          with_extract(true).\
          with_extract_path('/tmp').\
          with_creates(target_dir).\
          with_cleanup(true).\
          that_notifies('Exec[aerospike-install-server]')
      end

      case osfamily
      when 'Debian'
        it { is_expected.to contain_exec('aerospike-install-server').with_command("#{target_dir}/asinstall --force-confold -i") }
      when 'RedHat'
        it { is_expected.to contain_exec('aerospike-install-server').with_command("#{target_dir}/asinstall -Uvh") }
      end

      it do
        is_expected.to contain_user('as_user').\
          with_ensure('present').\
          with_uid(511).\
          with_gid('as_group').\
          with_shell('/bin/bash')
      end

      it do
        is_expected.to contain_group('as_group').\
          with_ensure('present').\
          with_gid(512).\
          that_comes_before('User[as_user]')
      end

      # Tests related to the aerospike::config class
      # Especially the erb
      it do
        is_expected.to create_file('/etc/aerospike/aerospike.conf').\
          with_content(%r{^\s*user as_user$}).\
          with_content(%r{^\s*group as_group$}).\
          with_content(%r{^\s*paxos-single-replica-limit 2$}).\
          with_content(%r{^\s*pidfile /run/aerospike/asd.pid$}).\
          with_content(%r{^\s*service-threads 8$}).\
          with_content(%r{^\s*scan-thread 6$}).\
          with_content(%r{^\s*transaction-queues 2$}).\
          with_content(%r{^\s*transaction-threads-per-queue 4$}).\
          with_content(%r{^\s*proto-fd-max 20000$}).\
          with_content(%r{^\s*file /var/log/aerospike/aerospike.log \{$}).\
          with_content(%r{^\s*context any info$}).\
          with_content(%r{^\s*file /var/log/aerospike/aerospike.debug \{$}).\
          with_content(%r{^\s*context cluster debug$}).\
          with_content(%r{^\s*context migrate debug$}).\
          with_content(%r{^\s*access-address 192.168.1.100$}).\
          with_content(%r{^\s*address any$}).\
          with_content(%r{^\s*port 4000$}).\
          with_content(%r{^\s*mode mesh$}).\
          with_content(%r{^\s*address 192.168.1.100$}).\
          with_content(%r{^\s*mesh-seed-address-port 192.168.1.100 3002$}).\
          with_content(%r{^\s*mesh-seed-address-port 192.168.1.101 3002$}).\
          with_content(%r{^\s*mesh-seed-address-port 192.168.1.102 3002$}).\
          with_content(%r{^\s*port 3002$}).\
          with_content(%r{^\s*interval 150$}).\
          with_content(%r{^\s*timeout 10$}).\
          with_content(%r{^\s*namespace bar \{$}).\
          with_content(%r{^\s*namespace foo \{$}).\
          with_content(%r{^\s*replication-factor 2$}).\
          with_content(%r{^\s*memory-size 10G$}).\
          with_content(%r{^\s*default-ttl 30d$}).\
          with_content(%r{^\s*storage-engine memory$}).\
          with_content(%r{^\s*storage-engine device \{$}).\
          with_content(%r{^\s*file /data/aerospike/foo.dat$}).\
          with_content(%r{^\s*filesize 10G$}).\
          with_content(%r{^\s*data-in-memory false$}).\
          with_content(%r{^\s*cluster \{$}).\
          with_content(%r{^\s*mode dynamic$}).\
          with_content(%r{^\s*self-group-id 201$}).\
          with_content(%r{^\s*security \{$}).\
          with_content(%r{^\s*privilege-refresh-period 500$}).\
          with_content(%r{^\s*syslog \{$}).\
          with_content(%r{^\s*local 0$}).\
          with_content(%r{^\s*report-user-admin true$}).\
          with_content(%r{^\s*report-authentication true$}).\
          with_content(%r{^\s*report-data-op foo true$}).\
          with_content(%r{^\s*log \{$}).\
          with_content(%r{^\s*report-violation true$}).\
          with_content(%r{^\s*xdr \{$}).\
          with_content(%r{^\s*enable-xdr true$}).\
          with_content(%r{^\s*xdr-namedpipe-path /tmp/xdr_pipe$}).\
          with_content(%r{^\s*xdr-digestlog-path /opt/aerospike/digestlog 100G$}).\
          with_content(%r{^\s*xdr-errorlog-path /var/log/aerospike/asxdr.log$}).\
          with_content(%r{^\s*xdr-pidfile /var/run/aerospike/asxdr.pid$}).\
          with_content(%r{^\s*local-node-port 4000$}).\
          with_content(%r{^\s*xdr-info-port 3004$}).\
          with_content(%r{^\s*datacenter DC1 \{$}).\
          with_content(%r{^\s*dc-node-address-port 172.68.17.123 3000$}).\
          with_content(%r{^\s*mod-lua \{$}).\
          with_content(%r{^\s*user-path /opt/aerospike/usr/udf/lua$})
      end

      # Tests related to the aerospike::service class
      it do
        is_expected.to contain_service('aerospike').\
          with_ensure('stopped').\
          with_enable(true).\
          with_hasrestart(true).\
          with_hasstatus(true).\
          with_provider('init')
      end
    end

    # #####################################################################
    # Tests creating a file with XDR credentials
    # #####################################################################
    describe "try create a file with XDR credentials - defined default params on #{osfamily}" do
      let(:params) { { config_xdr_credentials: {} } }
      let(:facts) do
        {
          osfamily: osfamily,
          operatingsystem: dist,
          operatingsystemmajrelease: majrelease
        }
      end

      # The details of the test of Aerospike::Xdr_credentials_file define are in
      # spec/defines/xdr_credentials_file_spec.rb
      it { is_expected.not_to contain_Aerospike__Xdr_credentials_file('') }
    end

    describe "create a file with XDR credentials on #{osfamily}" do
      let(:params) { { config_xdr_credentials: { 'DC1' => { 'username' => 'xdr_user_DC1', 'password' => 'xdr_password_DC1' } } } }
      let(:facts) do
        {
          osfamily: osfamily,
          operatingsystem: dist,
          operatingsystemmajrelease: majrelease
        }
      end

      # The details of the test of Aerospike::Xdr_credentials_file define are in
      # spec/defines/xdr_credentials_file_spec.rb
      it { is_expected.to contain_Aerospike__Xdr_credentials_file('DC1') }
    end

    # #####################################################################
    # Tests multiple datacenter replication for a given namespace
    # #####################################################################
    describe "Tests multiple datacenter replication for a given namespace on #{osfamily}" do
      let(:params) do
        {
          config_ns: {
            'foo' => {
              'enable-xdr'            => true,
              'xdr-remote-datacenter' => %w(DC1 DC2)
            }
          },
          config_xdr: {
            'enable-xdr'         => true,
            'xdr-digestlog-path' => '/opt/aerospike/digestlog 100G',
            'xdr-errorlog-path'  => '/var/log/aerospike/asxdr.log',
            'xdr-pidfile'        => '/var/run/aerospike/asxdr.pid',
            'local-node-port'    => 4000,
            'xdr-info-port'      => 3004,
            'datacenter DC1'     => [
              'dc-node-address-port 172.1.1.100 3000'
            ],
            'datacenter DC2' => [
              'dc-node-address-port 172.2.2.100 3000'
            ]
          }
        }
      end
      let(:facts) do
        {
          osfamily: osfamily,
          operatingsystem: dist,
          operatingsystemmajrelease: majrelease
        }
      end

      it { is_expected.to compile.with_all_deps }
      it do
        is_expected.to create_file('/etc/aerospike/aerospike.conf').\
          with_content(%r{^\s*namespace foo \{$}).\
          with_content(%r{^\s*enable-xdr true$}).\
          with_content(%r{^\s*xdr-remote-datacenter DC1$}).\
          with_content(%r{^\s*xdr-remote-datacenter DC2$}).\
          with_content(%r{^\s*xdr-digestlog-path /opt/aerospike/digestlog 100G$}).\
          with_content(%r{^\s*xdr-errorlog-path /var/log/aerospike/asxdr.log$}).\
          with_content(%r{^\s*xdr-pidfile /var/run/aerospike/asxdr.pid$}).\
          with_content(%r{^\s*local-node-port 4000$}).\
          with_content(%r{^\s*xdr-info-port 3004$}).\
          with_content(%r{^\s*datacenter DC1 \{$}).\
          with_content(%r{^\s*dc-node-address-port 172.1.1.100 3000$}).\
          with_content(%r{^\s*datacenter DC2 \{$}).\
          with_content(%r{^\s*dc-node-address-port 172.2.2.100 3000$})
      end
    end

    # #####################################################################
    # Test for the manage_service set to false
    # #####################################################################
    describe 'manage_service set to false' do
      let(:params) { { manage_service: false } }
      let(:facts) do
        {
          osfamily: osfamily,
          operatingsystem: dist,
          operatingsystemmajrelease: majrelease
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('aerospike::install').that_comes_before('Class[aerospike::config]') }
      it { is_expected.to contain_class('aerospike::config').that_comes_before('Class[aerospike::service]') }
      it { is_expected.to contain_class('aerospike::service') }
      # the service should not subscribe to the config but should be present
      it { is_expected.not_to contain_class('aerospike::service').that_subscribes_to('Class[aerospike::config]') }

      it { is_expected.not_to contain_service('aerospike') }
      # We still manage the config file
      it { is_expected.to create_file('/etc/aerospike/aerospike.conf') }
    end
  end

  context 'supported operating systems - aerospike-server-related tests' do
    # execute shared tests on various distributions
    # parameters :                  osfamily, dist, majrelease, expected_tag
    it_behaves_like 'supported_os', 'Debian', 'Debian', '8', 'debian8'
    it_behaves_like 'supported_os', 'Debian', 'Ubuntu', '16.04', 'ubuntu16.04'
    it_behaves_like 'supported_os', 'RedHat', 'RedHat', '7', 'el7'
  end

  # #####################################################################
  # Test for the restart_on_config_change set to false
  # #####################################################################
  describe 'restart_on_config_change set to false' do
    let(:params) { { restart_on_config_change: false } }
    let(:facts) do
      {
        osfamily: 'Debian',
        operatingsystem: 'Ubuntu',
        operatingsystemmajrelease: '16.04'
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('aerospike::install').that_comes_before('Class[aerospike::config]') }
    it { is_expected.to contain_class('aerospike::config').that_comes_before('Class[aerospike::service]') }
    it { is_expected.to contain_class('aerospike::service') }
    # the service should not subscribe to the config but should be present
    it { is_expected.not_to contain_class('aerospike::service').that_subscribes_to('Class[aerospike::config]') }

    # That's the big difference compared to manage_service
    it { is_expected.to contain_service('aerospike') }
    # We still manage the config file
    it { is_expected.to create_file('/etc/aerospike/aerospike.conf') }
  end

  describe 'allow changing service provider' do
    let(:params) { { service_provider: 'systemd' } }
    let(:facts) do
      {
        osfamily: 'Debian',
        operatingsystem: 'Ubuntu',
        operatingsystemmajrelease: '16.04'
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('aerospike::install').that_comes_before('Class[aerospike::config]') }
    it { is_expected.to contain_class('aerospike::config').that_comes_before('Class[aerospike::service]') }
    it { is_expected.to contain_class('aerospike::service') }

    it { is_expected.to contain_service('aerospike').with_hasrestart(true).with_hasstatus(true).with_provider('systemd') }
  end

  describe 'allow modifying asinstall parameters' do
    let(:params) { { asinstall_params: '--force-confnew -i' } }
    let(:facts) do
      {
        osfamily: 'Debian',
        operatingsystem: 'Debian',
        operatingsystemmajrelease: '8'
      }
    end

    let(:target_dir) { '/usr/local/src/aerospike-server-community-3.8.4-debian8' }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_class('aerospike::install').that_comes_before('Class[aerospike::config]') }
    it { is_expected.to contain_class('aerospike::config').that_comes_before('Class[aerospike::service]') }
    it { is_expected.to create_file('/etc/aerospike/aerospike.conf') }

    it { is_expected.to contain_exec('aerospike-install-server').with_command("#{target_dir}/asinstall --force-confnew -i") }
  end

  shared_examples 'amc-related' do |osfamily, dist, majrelease|
    # Here we enforce only the amc_version as this test would be useless if we
    # change the defautl version.
    describe "aerospike class without any parameters on #{osfamily}" do
      let(:params) do
        {
          amc_version: '3.6.6',
          service_provider: 'init'
        }
      end
      let(:facts) do
        {
          osfamily: osfamily,
          operatingsystem: dist,
          operatingsystemmajrelease: majrelease
        }
      end

      it { is_expected.to compile.with_all_deps }

      # Tests related to the aerospike::install class
      it { is_expected.not_to contain_archive('/usr/local/src/aerospike-amc-community-3.6.6.all.x86_64.deb') }
      it { is_expected.not_to contain_package('aerospike-amc-community') }

      # Tests related to the aerospike::config class

      # Tests related to the aerospike::service class
      it { is_expected.not_to contain_service('amc') }
      it { is_expected.to contain_service('aerospike').with_hasrestart(true).with_hasstatus(true).with_provider('init') }
    end

    describe "aerospike class with all amc-related parameters on #{osfamily}" do
      let(:params) do
        {
          amc_install: true,
          amc_version: '3.6.5',
          amc_download_dir: '/tmp',
          amc_download_url: 'http://my_fileserver.example.com/aerospike/aerospike-amc-community-3.6.5.all.x86_64.deb',
          amc_manage_service: true,
          amc_service_status: 'stopped'
        }
      end
      let(:facts) do
        {
          osfamily: osfamily,
          operatingsystem: 'Debian',
          operatingsystemmajrelease: '8'
        }
      end

      # Tests related to the aerospike::install class
      it { is_expected.to contain_package('python-pip').with_ensure('installed').that_comes_before('Package[bcrypt]') }
      it { is_expected.to contain_package('ansible').with_ensure('installed') }
      it { is_expected.to contain_package('python-paramiko').with_ensure('installed') }

      it { is_expected.to contain_package('markupsafe').with_ensure('installed').with_provider('pip') }
      it { is_expected.to contain_package('ecdsa').with_ensure('installed').with_provider('pip') }
      it { is_expected.to contain_package('pycrypto').with_ensure('installed').with_provider('pip') }

      it { is_expected.to contain_package('build-essential').with_ensure('installed').that_comes_before('Package[bcrypt]') }
      it { is_expected.to contain_package('python-dev').with_ensure('installed').that_comes_before('Package[bcrypt]') }
      it { is_expected.to contain_package('libffi-dev').with_ensure('installed').that_comes_before('Package[bcrypt]') }
      it { is_expected.to contain_package('bcrypt').with_ensure('installed').with_provider('pip') }

      it do
        is_expected.to contain_archive('/tmp/aerospike-amc-community-3.6.5.all.x86_64.deb').\
          with_ensure('present').\
          with_source('http://my_fileserver.example.com/aerospike/aerospike-amc-community-3.6.5.all.x86_64.deb').\
          with_extract(false).\
          with_extract_path('/tmp').\
          with_creates('/tmp/aerospike-amc-community-3.6.5.all.x86_64.deb').\
          with_cleanup(false)
      end

      it do
        is_expected.to contain_package('aerospike-amc-community').\
          with_ensure('latest').\
          with_provider('dpkg').\
          with_source('/tmp/aerospike-amc-community-3.6.5.all.x86_64.deb')
      end

      # Tests related to the aerospike::config class

      # Tests related to the aerospike::service class
      it do
        is_expected.to contain_service('amc').\
          with_ensure('stopped').\
          with_enable(true).\
          with_hasrestart(true).\
          with_hasstatus(true)
      end
    end
  end

  context 'supported operating systems - amc-related tests' do
    # execute shared tests on various distributions
    # parameters :                  osfamily, dist, majrelease
    it_behaves_like 'amc-related', 'Debian', 'Debian', '8'
    it_behaves_like 'amc-related', 'Debian', 'Ubuntu', '16.04'
  end
end
