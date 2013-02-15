# = Class: pulp
#
# == This module manages pulp
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
class pulp::package {
  package {
    'pulp':
      ensure => 'present';
    'pulp-admin':
      ensure => 'present';
  }




  exec { 'pulpinit':
    command     => '/etc/init.d/pulp-server init && touch /var/lib/pulp/init.flag',
    creates     => '/var/lib/pulp/init.flag',
    require     => Package['pulp'],
  }
}
