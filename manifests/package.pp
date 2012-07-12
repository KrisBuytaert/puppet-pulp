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



  file {
    '/var/lib/pulp/init.flag':
      require => Exec['pulpinit']
  }

  exec { 'pulpinit':
    command     => '/etc/init.d/pulp-server init ',
    refreshonly => true,
    creates     => '/var/lib/pulp/.inited',
    require     => Package['pulp'],
  }
}
