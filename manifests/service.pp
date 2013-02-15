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
class pulp::service {

  service {
    # When you run into AutoReconnect: could not find master/primary
    # It means mongodb ain't running
    # Move mongo out ot is's own module
    'mongod':
      ensure  => 'running',
      enabled => true;

    'httpd':
      ensure  => 'running',
      enabled => true,
      require => [File['/var/lib/pulp/init.flag'], Class['package']];
  }

}
