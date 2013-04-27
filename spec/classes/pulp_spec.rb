#noinspection RubyResolve
require 'spec_helper'

describe 'pulp', :type => :class do
  context 'Install and configure Pulp version 1' do
    let :facts do {
        :osfamily => 'RedHat'
    }
    end

    let :params do {
        :pulp_version => '1',
    }
    end

    it { should contain_package('pulp').with_ensure('present') }
    it { should contain_package('pulp-admin').with_ensure('present') }
    it { should contain_file('/var/lib/pulp/init.flag').with( :require => 'Exec[pulpinit]') }
    it { should contain_exec('pulpinit').with( :creates => '/var/lib/pulp/init.flag') }
  end
end
