require 'spec_helper_acceptance'

describe 'aerospike class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'work idempotently with no errors' do
      pp = <<-EOS
      class { 'aerospike': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('aerospike') do
      it { is_expected.to be_installed }
    end

    describe service('aerospike') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
