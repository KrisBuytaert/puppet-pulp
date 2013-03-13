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
  $mail_host        = 'localhost',
  $mail_host_port   = '25',
  $mail_from        = undef,
  $mongodb_host     = 'localhost',
  $mongodb_port     = '27017',
  $qpid_server      = 'localhost',
  $qpid_port        = '5672',
  $pulp_server_name = false
) {
  $packagelist = ['pulp-puppet-plugins', 'pulp-rpm-plugins', 'pulp-selinux', 'pulp-server']

  package { $packagelist:
    ensure => installed,
  }
  file { '/etc/pulp/server.conf':
    owner => 'root',
    group => 'root',
    mode => 0644,
    content => template('pulp/server.conf.erb'),
  }

}
