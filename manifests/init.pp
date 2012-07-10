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
class pulp {
  package {
    'pulp':
      ensure => 'present';
    'pulp-admin':
      ensure => 'present';
  }



  service {
    # When you run into AutoReconnect: could not find master/primary
    # It means mongodb ain't running
    # Move mongo out ot is's own module
    'mongod':
      ensure => 'running';

    'pulp-server':
      ensure  => 'running',
      require => [File['/var/lib/pulp/init.flag'],Package['pulp']];
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
