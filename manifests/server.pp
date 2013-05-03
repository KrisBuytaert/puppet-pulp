# = Class: pulp::server
#
# == This module manages pulp server
#
# == Parameters
#
# [*mail_enabled*]
#   Enable smtp mail.
#
# [*mail_host*]
#   IP address or FQDN of SMTP mail host.
#
# [*mail_host_port*]
#   SMTP port (default: 25)
#
# [*mail_from*]
#   Set mail from email address.
#
# [*mongodb_host*]
#   MongoDB database host (default: localhost.localdomain)
#
# [*mongodb_port*]
#   MongoDB port (default: 27017)
#
# [*qpid_server*]
#   Qpid messaging host.
#
# [*qpid_port*]
#   Qpid port (default: 5672)
#
# [*pulp_server_name*]
#   Pulp server host.
#
# [*migrate_attempts*]
#   Maximum number of attempts to execute pulp-manage-db to initialize the new
#   types in Pulp’s database.
#
# [*migrate_wait_secs*]
#   Seconds to wait between retry attempts to execute pulp-manage-db.
#
# [*package_version*]
#   Set installation version e.g. 2.1.0, installed or latest.
#
# == Actions
#
# == Requires
#
# == Sample Usage
#
# == Todo
#
class pulp::server (
  $mail_enabled      = 'false',
  $mail_host         = 'localhost.localdomain',
  $mail_host_port    = '25',
  $mail_from         = undef,
  $mongodb_host      = 'localhost.localdomain',
  $mongodb_port      = '27017',
  $qpid_server       = 'localhost.localdomain',
  $qpid_port         = '5672',
  $pulp_server_host  = 'localhost.localdomain',
  $migrate_attempts  = '3',
  $migrate_wait_secs = '5',
  $package_version   = 'installed'
) {
  $packagelist = ['pulp-puppet-plugins', 'pulp-rpm-plugins', 'pulp-selinux', 'pulp-server']

  package { $packagelist:
    ensure => $package_version,
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
    notify      => Service['httpd'],
    require     => [ Package['pulp-server'], Service['mongod']],
    tries       => $migrate_attempts,
    try_sleep   => $migrate_wait_secs,
  }
}
