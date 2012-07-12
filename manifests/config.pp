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
class pulp::config {

  file { '/etc/pulp/admin/admin.conf':
    ensure     => 'file',
    group      => '0',
    mode       => '0644',
    owner      => '0',
  }

  file { '/etc/pulp/admin/task.conf':
    ensure     => 'file',
    group      => '0',
    mode       => '0644',
    owner      => '0',
  }

}
