require 'spec_helper'

describe 'aerospike::xdr_credentials_file' do

  context 'definition of a credentials for DC1' do
    let (:title) { 'DC1' }
    let (:params) {
      {
        :all_xdr_credentials => {"DC1"=>{"username"=>"xdr_user_DC1", "password"=>"xdr_password_DC1"}},
      }
    }

    it do
      should contain_file('/etc/aerospike/security-credentials_DC1.txt').with({
        'ensure' => 'present',
        'mode'   => '0600',
        'owner'  => nil,
        'group'  => nil,
        })\
        .with_content(/^credentials$/)\
        .with_content(/username xdr_user_DC1$/)\
        .with_content(/password xdr_password_DC1$/)
    end
  end

end
