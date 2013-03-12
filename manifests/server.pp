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
  $qpid_server = 'localhost'
) {
  $packagelist = ['pulp-puppet-plugins', 'pulp-rpm-plugins', 'pulp-selinux', 'pulp-server']

  package { $packagelist:
      ensure => installed,
  }

}
