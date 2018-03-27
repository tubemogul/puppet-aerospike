require 'spec_helper'

describe 'aerospike::xdr_credentials_file' do
  context 'definition of a credentials for DC1' do
    let(:title) { 'DC1' }
    let(:params) do
      {
        all_xdr_credentials: { 'DC1' => { 'username' => 'xdr_user_DC1', 'password' => 'xdr_password_DC1' } }
      }
    end

    it do
      is_expected.to contain_file('/etc/aerospike/security-credentials_DC1.txt').\
        with_ensure('present').\
        with_mode('0600').\
        with_owner('root').\
        with_group('root').\
        with_content(%r{^credentials$}).\
        with_content(%r{username xdr_user_DC1$}).\
        with_content(%r{password xdr_password_DC1$}).\
        without_notify
    end
  end
end
