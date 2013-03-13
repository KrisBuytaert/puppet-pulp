# = Class: pulp::server
#
# == This module manages pulp server
#
# == Parameters
#
# == Actions
#
# == Requires
#
# == Sample Usage
#
# == Todo
#
#  * Add documentation.
#
class pulp::server (
  $mail_enabled     = 'false',
  $mail_host        = 'localhost.localdomain',
  $mail_host_port   = '25',
  $mail_from        = undef,
  $mongodb_host     = 'localhost.localdomain',
  $mongodb_port     = '27017',
  $qpid_server      = 'localhost.localdomain',
  $qpid_port        = '5672',
  $pulp_server_name = false
) {
  $packagelist = ['pulp-puppet-plugins', 'pulp-rpm-plugins', 'pulp-selinux', 'pulp-server']

  package { $packagelist:
    ensure => installed,
  }
  file { '/etc/pulp/server.conf':
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    content => template('pulp/server.conf.erb'),
  }
  service { 'httpd':
    ensure => 'running',
    enable => $enabled,
  }
  service { 'mongod':
    ensure => 'running',
    enable => $enabled,
  }
  service { 'qpidd':
    ensure => 'running',
    enable => $eanbled,
  }
  file { '/var/lib/pulp/init.flag':
    ensure  => 'file',
    notify  => Exec['manage_pulp_databases']
  }
  exec { 'manage_pulp_databases':
    command     => '/usr/bin/pulp-manage-db ',
    refreshonly => true,
    creates     => '/var/lib/pulp/.inited',
    require     => Package['pulp-server'],
  }
}
