require 'spec_helper'

describe 'pulp', :type => :class do
  context 'Install Pulp' do
    let :facts do {
        :osfamily => 'RedHat'
    }
    end

    it { should contain_package('pulp').with_ensure('present') }
  end

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
    it { should contain_file('/etc/pulp/admin/admin.conf').with(
                    :ensure => 'file',
                    :group  => '0',
                    :mode   => '0644',
                    :owner  => '0'
                )
    }
    it { should contain_file('/etc/pulp/admin/task.conf').with(
                    :ensure => 'file',
                    :group  => '0',
                    :mode   => '0644',
                    :owner  => '0'
                )
    }
    it { should contain_service('mongod').with( :ensure => 'running') }
    it { should contain_service('pulp-server').with(
                    :ensure  => 'running',
                    :require => '[File[/var/lib/pulp/init.flag]{:path=>"/var/lib/pulp/init.flag"}, Package[pulp]{:name=>"pulp"}]'
                )
    }
  end

  context 'Setup Pulp Project version 2 Yum Repository' do
    let :facts do {
        :osfamily => 'RedHat'
    }
    end

    let :params do {
        :pulp_version => '2',
        :repo_enabled => true
    }
    end

    it { should contain_yumrepo('rhel-pulp') }
  end

  context 'Install Pulp Project version 2 Server' do
    let :facts do {
        :osfamily => 'RedHat'
    }
    end

    let :params do {
        :pulp_version => '2',
        :pulp_server  => true,
        :mail_from => 'pulpadmin@example.net'
    }
    end

    it { should contain_package('pulp-puppet-plugins').with( :ensure => 'installed') }
    it { should contain_package('pulp-rpm-plugins').with( :ensure => 'installed') }
    it { should contain_package('pulp-selinux').with( :ensure => 'installed') }
    it { should contain_package('pulp-server').with( :ensure => 'installed') }
    it { should contain_file('/etc/pulp/server.conf').with(
        :owner => 'root',
        :group => 'root',
        :mode  => '0644'
                )
    }
    it { should contain_file('/etc/pulp/server.conf').with_content(/server_name:\slocalhost.localdomain/) }
    it { should contain_file('/etc/pulp/server.conf').with_content(/seeds:\slocalhost.localdomain:27017/) }
    it { should contain_file('/etc/pulp/server.conf').with_content(/url:\stcp:\/\/localhost.localdomain:5672/) }
    it { should contain_file('/etc/pulp/server.conf').with_content(/host:\slocalhost.localdomain/) }
    it { should contain_file('/etc/pulp/server.conf').with_content(/port:\s25/) }
    it { should contain_file('/etc/pulp/server.conf').with_content(/from:\spulpadmin@example.net/) }
    it { should contain_file('/etc/pulp/server.conf').with_content(/enabled:\sfalse/) }

    it { should contain_service('httpd').with( :ensure => 'running')}
    it { should contain_service('mongod').with( :ensure => 'running')}
    it { should contain_service('qpidd').with( :ensure => 'running')}
    it { should contain_file('/var/lib/pulp/init.flag').with(
                    :ensure => 'file',
                    :notify => 'Exec[manage_pulp_databases]'
                )
    }
    it { should contain_exec('manage_pulp_databases').with(
                    :creates => '/var/lib/pulp/.inited',
                    :refreshonly => 'true',
                    :notify => 'Service[httpd]',
                    :require => '[Package[pulp-server]{:name=>"pulp-server"}, Service[mongod]{:name=>"mongod"}]'
                )
    }
  end

  context 'Install Pulp Project version 2 Client (Agent)' do
    let :facts do {
        :osfamily => 'RedHat'
    }
    end

    let :params do {
        :pulp_version => '2',
        :pulp_client  => true
    }
    end

    it { should contain_package('pulp-agent').with( :ensure => 'installed') }
    it { should contain_package('pulp-consumer-client').with( :ensure => 'installed') }
    it { should contain_package('pulp-puppet-handlers').with( :ensure => 'installed') }
    it { should contain_package('pulp-rpm-consumer-extensions').with( :ensure => 'installed') }
    it { should contain_package('pulp-rpm-handlers').with( :ensure => 'installed') }
    it { should contain_file('/etc/pulp/consumer/consumer.conf').with(
        :ensure => 'file',
        :notify => 'Service[goferd]'
                )
    }
    it { should contain_service('goferd').with(
        :ensure => 'running',
        :enable => 'true'
                )
    }
  end

  context 'Install Pulp Project version 2 Administration Client' do
    let :facts do {
        :osfamily => 'RedHat'
    }
    end

    let :params do {
        :pulp_version => '2',
        :pulp_admin  => true
    }
    end

    it { should contain_package('pulp-admin-client').with( :ensure => 'installed') }
    it { should contain_package('pulp-puppet-admin-extensions').with( :ensure => 'installed') }
    it { should contain_package('pulp-rpm-admin-extensions').with( :ensure => 'installed') }
    it { should contain_file('/etc/pulp/admin/admin.conf').with(
        :ensure => 'file',
        :mode => '0644',
        :owner => 'root',
        :group => 'root'
                )
    }
    it { should contain_file('/etc/pulp/admin/admin.conf').with_content(/host\s=\slocalhost.localdomain/)}
    it { should contain_file('/etc/pulp/admin/admin.conf').with_content(/port\s=\s443/)}
  end

  context 'Install specific package version of pulp server version 2' do
    let :fact do {
        :osfamily => 'RedHat'
    }
    end

    let :params do {
        :pulp_version => '2',
        :pulp_server  => true,
        :package_version => '2.1.0'
    }
    end

    it { should contain_package('pulp-server').with( :ensure => '2.1.0') }
    it { should contain_package('pulp-selinux').with( :ensure => '2.1.0') }
    it { should contain_package('pulp-rpm-plugins').with( :ensure => '2.1.0') }
    it { should contain_package('pulp-puppet-plugins').with( :ensure => '2.1.0') }
  end

  context 'Install default package version of pulp server version 2' do
    let :fact do {
        :osfamily => 'RedHat'
    }
    end

    let :params do {
        :pulp_version => '2',
        :pulp_server  => true
    }
    end

    it { should contain_package('pulp-server').with( :ensure => 'installed') }
    it { should contain_package('pulp-selinux').with( :ensure => 'installed') }
    it { should contain_package('pulp-rpm-plugins').with( :ensure => 'installed') }
    it { should contain_package('pulp-puppet-plugins').with( :ensure => 'installed') }
  end

end
