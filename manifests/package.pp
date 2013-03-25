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
  #Installed by pulp-server group
  package {
    'pulp-server':
      ensure => 'present';
    'pulp-selinux':
      ensure => 'present';
    'pulp-rpm-plugins':
      ensure => 'present';
    'pulp-puppet-plugins':
      ensure => 'present';
  }

  #Installed by pulp-admin group
  package {
    'pulp-rpm-admin-extensions':
      ensure => 'present';
    'pulp-puppet-admin-extensions':
      ensure => 'present';
    'pulp-admin-client':
      ensure => 'present';
  }
}
