require 'spec_helper'

describe 'aerospike' do
  context 'supported operating systems - aerospike-server-related tests' do
    ['Debian'].each do |osfamily|

      # #####################################################################
      # Basic compilation test with all parameters to default
      # #####################################################################
      describe "aerospike class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        # Tests related to the aerospike base class content
        it { should create_class('aerospike') }
        it { should contain_class('aerospike::install').that_comes_before('Class[aerospike::config]') }
        it { should contain_class('aerospike::config') }
        it { should contain_class('aerospike::service').that_subscribes_to('Class[aerospike::config]') }

        # Tests related to the aerospike::install class
        it { should contain_class('archive') }
        it { is_expected.to contain_archive('/usr/local/src/aerospike-server-community-3.8.4-ubuntu14.04.tgz') }
        it { is_expected.to contain_exec('aerospike-install-server') }
        it { is_expected.to contain_user('root') }
        it { is_expected.to contain_group('root') }

        # Tests related to the aerospike::config class
        it do
          is_expected.to create_file('/etc/aerospike/aerospike.conf')\
            .without_content(/^\s*cluster {$/)\
            .without_content(/^\s*security {$/)\
            .without_content(/^\s*xdr {$/)
        end

        # Tests related to the aerospike::service class
        it do
          should contain_service('aerospike')\
            .with_ensure('running')
        end
      end

      # #####################################################################
      # Tests with just custom urls (specific case)
      # #####################################################################
      describe "aerospike class with custom url on #{osfamily}" do
        let(:params) {{
          :version        => '3.8.3',
          :download_url   => 'http://my_fileserver.example.com/aerospike/aerospike-server-enterprise-3.8.3-ubuntu14.04.tgz',
          :edition        => 'enterprise',
          :target_os_tag  => 'ubuntu14.04',
        }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        it do
          is_expected.to contain_archive('/usr/local/src/aerospike-server-enterprise-3.8.3-ubuntu14.04.tgz')\
            .with_ensure('present')\
            .with_source('http://my_fileserver.example.com/aerospike/aerospike-server-enterprise-3.8.3-ubuntu14.04.tgz')\
            .with_extract(true)\
            .with_extract_path('/usr/local/src')\
            .with_creates('/usr/local/src/aerospike-server-enterprise-3.8.3-ubuntu14.04')\
            .with_cleanup(false)
        end

        it { is_expected.to contain_exec('aerospike-install-server') }

      end

      # #####################################################################
      # Test with every parameter (except the custom urls covered earlier)
      # #####################################################################
      describe "aerospike class with all parameters (except custom url) on #{osfamily}" do
        let(:params) {{
          :version        => '3.8.3',
          :download_dir   => '/tmp',
          :remove_archive => true,
          :edition        => 'enterprise',
          :target_os_tag  => 'ubuntu12.04',
          :download_user  => 'dummy_user',
          :download_pass  => 'dummy_password',
          :system_user    => 'as_user',
          :system_uid     => 511,
          :system_group   => 'as_group',
          :system_gid     => 512,
          :config_service => {
            'paxos-single-replica-limit'    => 2,
            'pidfile'                       => '/run/aerospike/asd.pid',
            'service-threads'               => 8,
            'scan-thread'                   => 6,
            'transaction-queues'            => 2,
            'transaction-threads-per-queue' => 4,
            'proto-fd-max'                  => 20000,
          },
          :config_logging => {
            '/var/log/aerospike/aerospike.log' => [ 'any info', ],
            '/var/log/aerospike/aerospike.debug' => [ 'cluster debug', 'migrate debug', ],
          },
          :config_net_svc => {
            'address'        => 'any',
            'port'           => 4000,
            'access-address' => '192.168.1.100',
          },
          :config_net_fab => {
            'address' => 'any',
            'port'    => 4001,
          },
          :config_net_inf => {
            'address' => 'any',
            'port'    => 4003,
          },
          :config_net_hb => {
            'mode'                   => 'mesh',
            'address'                => '192.168.1.100',
            'mesh-seed-address-port 192.168.1.100' => '3002',
            'mesh-seed-address-port 192.168.1.101' => '3002',
            'mesh-seed-address-port 192.168.1.102' => '3002',
            'port'                   => 3002,
            'interval'               => 150,
            'timeout'                => 10,
          },
          :config_ns => {
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
          :config_cluster => {
            'mode' => 'dynamic',
            'self-group-id' => 201,
          },
          :config_sec                  => {
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
          :config_xdr => {
            'enable-xdr' => true,
            'xdr-namedpipe-path' => '/tmp/xdr_pipe',
            'xdr-digestlog-path' => '/opt/aerospike/digestlog 100G',
            'xdr-errorlog-path' => '/var/log/aerospike/asxdr.log',
            'xdr-pidfile' => '/var/run/aerospike/asxdr.pid',
            'local-node-port' => 4000,
            'xdr-info-port' => 3004,
            'datacenter DC1' => [
              'dc-node-address-port 172.68.17.123 3000',
            ],
          },
          :service_status => 'stopped',
        }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }

        # Tests related to the aerospike base class content
        it { should create_class('aerospike') }
        it { should contain_class('aerospike::install').that_comes_before('Class[aerospike::config]') }
        it { should contain_class('aerospike::config') }
        it { should contain_class('aerospike::service').that_subscribes_to('Class[aerospike::config]') }

        # Tests related to the aerospike::install class
        it do
          is_expected.to contain_archive('/tmp/aerospike-server-enterprise-3.8.3-ubuntu12.04.tgz')\
            .with_ensure('present')\
            .with_source('http://www.aerospike.com/artifacts/aerospike-server-enterprise/3.8.3/aerospike-server-enterprise-3.8.3-ubuntu12.04.tgz')\
            .with_username('dummy_user')\
            .with_password('dummy_password')\
            .with_extract(true)\
            .with_extract_path('/tmp')\
            .with_creates('/tmp/aerospike-server-enterprise-3.8.3-ubuntu12.04')\
            .with_cleanup(true)
        end

        it { is_expected.to contain_exec('aerospike-install-server') }

        it do
          is_expected.to contain_user('as_user')\
            .with_ensure('present')\
            .with_uid(511)\
            .with_gid('as_group')\
            .with_shell('/bin/bash')
        end

        it do
          is_expected.to contain_group('as_group')\
            .with_ensure('present')\
            .with_gid(512)\
            .that_comes_before('User[as_user]')
        end

        # Tests related to the aerospike::config class
        # Especially the erb
        it do
          is_expected.to create_file('/etc/aerospike/aerospike.conf')\
            .with_content(/^\s*user as_user$/)\
            .with_content(/^\s*group as_group$/)\
            .with_content(/^\s*paxos-single-replica-limit 2$/)\
            .with_content(/^\s*pidfile \/run\/aerospike\/asd.pid$/)\
            .with_content(/^\s*service-threads 8$/)\
            .with_content(/^\s*scan-thread 6$/)\
            .with_content(/^\s*transaction-queues 2$/)\
            .with_content(/^\s*transaction-threads-per-queue 4$/)\
            .with_content(/^\s*proto-fd-max 20000$/)\
            .with_content(/^\s*file \/var\/log\/aerospike\/aerospike.log {$/)\
            .with_content(/^\s*context any info$/)\
            .with_content(/^\s*file \/var\/log\/aerospike\/aerospike.debug {$/)\
            .with_content(/^\s*context cluster debug$/)\
            .with_content(/^\s*context migrate debug$/)\
            .with_content(/^\s*access-address 192.168.1.100$/)\
            .with_content(/^\s*address any$/)\
            .with_content(/^\s*port 4000$/)\
            .with_content(/^\s*mode mesh$/)\
            .with_content(/^\s*address 192.168.1.100$/)\
            .with_content(/^\s*mesh-seed-address-port 192.168.1.100 3002$/)\
            .with_content(/^\s*mesh-seed-address-port 192.168.1.101 3002$/)\
            .with_content(/^\s*mesh-seed-address-port 192.168.1.102 3002$/)\
            .with_content(/^\s*port 3002$/)\
            .with_content(/^\s*interval 150$/)\
            .with_content(/^\s*timeout 10$/)\
            .with_content(/^\s*namespace bar {$/)\
            .with_content(/^\s*namespace foo {$/)\
            .with_content(/^\s*replication-factor 2$/)\
            .with_content(/^\s*memory-size 10G$/)\
            .with_content(/^\s*default-ttl 30d$/)\
            .with_content(/^\s*storage-engine memory$/)\
            .with_content(/^\s*storage-engine device {$/)\
            .with_content(/^\s*file \/data\/aerospike\/foo.dat$/)\
            .with_content(/^\s*filesize 10G$/)\
            .with_content(/^\s*data-in-memory false$/)\
            .with_content(/^\s*cluster {$/)\
            .with_content(/^\s*mode dynamic$/)\
            .with_content(/^\s*self-group-id 201$/)\
            .with_content(/^\s*security {$/)\
            .with_content(/^\s*privilege-refresh-period 500$/)\
            .with_content(/^\s*syslog {$/)\
            .with_content(/^\s*local 0$/)\
            .with_content(/^\s*report-user-admin true$/)\
            .with_content(/^\s*report-authentication true$/)\
            .with_content(/^\s*report-data-op foo true$/)\
            .with_content(/^\s*log {$/)\
            .with_content(/^\s*report-violation true$/)\
            .with_content(/^\s*xdr {$/)\
            .with_content(/^\s*enable-xdr true$/)\
            .with_content(/^\s*xdr-namedpipe-path \/tmp\/xdr_pipe$/)\
            .with_content(/^\s*xdr-digestlog-path \/opt\/aerospike\/digestlog 100G$/)\
            .with_content(/^\s*xdr-errorlog-path \/var\/log\/aerospike\/asxdr.log$/)\
            .with_content(/^\s*xdr-pidfile \/var\/run\/aerospike\/asxdr.pid$/)\
            .with_content(/^\s*local-node-port 4000$/)\
            .with_content(/^\s*xdr-info-port 3004$/)\
            .with_content(/^\s*datacenter DC1 {$/)\
            .with_content(/^\s*dc-node-address-port 172.68.17.123 3000$/)
        end

        # Tests related to the aerospike::service class
        it do
          should contain_service('aerospike')\
            .with_ensure('stopped')\
            .with_enable(true)\
            .with_hasrestart(true)\
            .with_hasstatus(true)\
            .with_provider('init')
        end
      end

      # #####################################################################
      # Tests creating a file with XDR credentials
      # #####################################################################
      describe "try create a file with XDR credentials - defined default params on #{osfamily}" do
        let(:params) {{
          :config_xdr_credentials => {},
        }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        # The details of the test of Aerospike::Xdr_credentials_file define are in
        # spec/defines/xdr_credentials_file_spec.rb
        it { should_not contain_Aerospike__Xdr_credentials_file('') }
      end

      describe "create a file with XDR credentials on #{osfamily}" do
        let(:params) {{
          :config_xdr_credentials => {"DC1"=>{"username"=>"xdr_user_DC1", "password"=>"xdr_password_DC1"}},
        }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        # The details of the test of Aerospike::Xdr_credentials_file define are in
        # spec/defines/xdr_credentials_file_spec.rb
        it { should contain_Aerospike__Xdr_credentials_file('DC1') }
      end


      # #####################################################################
      # Tests multiple datacenter replication for a given namespace
      # #####################################################################
      describe "Tests multiple datacenter replication for a given namespace on #{osfamily}" do
        let(:params) {{
          :config_ns                  => {
            'foo'                     => {
              'enable-xdr'            => true,
              'xdr-remote-datacenter' => [ 'DC1', 'DC2' ],
            },
          },
          :config_xdr            => {
            'enable-xdr'         => true,
            'xdr-digestlog-path' => '/opt/aerospike/digestlog 100G',
            'xdr-errorlog-path'  => '/var/log/aerospike/asxdr.log',
            'xdr-pidfile'        => '/var/run/aerospike/asxdr.pid',
            'local-node-port'    => 4000,
            'xdr-info-port'      => 3004,
            'datacenter DC1'     => [
              'dc-node-address-port 172.1.1.100 3000',
            ],
            'datacenter DC2' => [
              'dc-node-address-port 172.2.2.100 3000',
            ],
          },
        }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { should compile.with_all_deps }
        it do
          is_expected.to create_file('/etc/aerospike/aerospike.conf')\
            .with_content(/^\s*namespace foo {$/)\
            .with_content(/^\s*enable-xdr true$/)\
            .with_content(/^\s*xdr-remote-datacenter DC1$/)\
            .with_content(/^\s*xdr-remote-datacenter DC2$/)\
            .with_content(/^\s*xdr-digestlog-path \/opt\/aerospike\/digestlog 100G$/)\
            .with_content(/^\s*xdr-errorlog-path \/var\/log\/aerospike\/asxdr.log$/)\
            .with_content(/^\s*xdr-pidfile \/var\/run\/aerospike\/asxdr.pid$/)\
            .with_content(/^\s*local-node-port 4000$/)\
            .with_content(/^\s*xdr-info-port 3004$/)\
            .with_content(/^\s*datacenter DC1 {$/)\
            .with_content(/^\s*dc-node-address-port 172.1.1.100 3000$/)\
            .with_content(/^\s*datacenter DC2 {$/)\
            .with_content(/^\s*dc-node-address-port 172.2.2.100 3000$/)
        end
      end

      # #####################################################################
      # Test for the manage_service set to false
      # #####################################################################
      describe 'manage_service set to false' do
        let(:params) {{
          :manage_service => false,
        }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

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

      # #####################################################################
      # Test for the restart_on_config_change set to false
      # #####################################################################
      describe 'restart_on_config_change set to false' do
        let(:params) {{
          :restart_on_config_change => false,
        }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

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
        let(:params) {{
          :service_provider => 'systemd',
        }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('aerospike::install').that_comes_before('Class[aerospike::config]') }
        it { is_expected.to contain_class('aerospike::config').that_comes_before('Class[aerospike::service]') }
        it { is_expected.to contain_class('aerospike::service') }

        it { is_expected.to contain_service('aerospike')
             .with_hasrestart(true)\
             .with_hasstatus(true)\
             .with_provider('systemd')
        }
      end
    end
  end

  context 'supported operating systems - amc-related tests' do
    ['Debian'].each do |osfamily|
      # Here we enforce only the amc_version as this test would be useless if we
      # change the defautl version.
			describe "aerospike class without any parameters on #{osfamily}" do
				let(:params) {{
					:amc_version => '3.6.6',
        }}
				let(:facts) {{
					:osfamily => osfamily,
				}}

				it { should compile.with_all_deps }

				# Tests related to the aerospike::install class
        it { is_expected.to_not contain_archive('/usr/local/src/aerospike-amc-community-3.6.6.all.x86_64.deb') }
				it { is_expected.to_not contain_package('aerospike-amc-community') }

				# Tests related to the aerospike::config class

				# Tests related to the aerospike::service class
        it { is_expected.to_not contain_service('amc') }
				it { is_expected.to contain_service('aerospike').with_hasrestart(true)\
            .with_hasstatus(true)\
            .with_provider('init')
        }
			end

			describe "aerospike class with all amc-related parameters on #{osfamily}" do
				let(:params) {{
					:amc_install        => true,
					:amc_version        => '3.6.5',
					:amc_download_dir   => '/tmp',
					:amc_download_url   => 'http://my_fileserver.example.com/aerospike/aerospike-amc-community-3.6.5.all.x86_64.deb',
					:amc_manage_service => true,
					:amc_service_status => 'stopped',
				}}
				let(:facts) {{
					:osfamily => osfamily,
				}}

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
          is_expected.to contain_archive('/tmp/aerospike-amc-community-3.6.5.all.x86_64.deb')\
             .with_ensure('present')\
             .with_source('http://my_fileserver.example.com/aerospike/aerospike-amc-community-3.6.5.all.x86_64.deb')\
             .with_extract(false)\
             .with_extract_path('/tmp')\
             .with_creates('/tmp/aerospike-amc-community-3.6.5.all.x86_64.deb')\
             .with_cleanup(false)
        end

				it do
          is_expected.to contain_package('aerospike-amc-community')\
            .with_ensure('latest')\
            .with_provider('dpkg')\
            .with_source('/tmp/aerospike-amc-community-3.6.5.all.x86_64.deb')
        end

				# Tests related to the aerospike::config class

        # Tests related to the aerospike::service class
        it do
          should contain_service('amc')\
            .with_ensure('stopped')\
            .with_enable(true)\
            .with_hasrestart(true)\
            .with_hasstatus(true)\
            .with_provider('init')
        end
			end
		end
  end
end
