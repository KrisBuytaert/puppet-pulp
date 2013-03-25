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
class pulp (
  $pulp_version      = '1',
  $pulp_server       = false,
  $pulp_client       = false,
  $pulp_admin        = false,
  $pulp_server_host  = 'localhost.localdomain',
  $pulp_server_port  = '443',
  $mail_enabled      = 'false',
  $mail_host         = 'localhost.localdomain',
  $mail_host_port    = '25',
  $mail_from         = undef,
  $mongodb_host      = 'localhost.localdomain',
  $mongodb_port      = '27017',
  $qpid_server       = 'localhost.localdomain',
  $qpid_port         = '5672',
  $migrate_attempts  = '3',
  $migrate_wait_secs = '5'
) {

  #Validation
  validate_re($pulp_version, '^[1-2]$')
  validate_bool($pulp_server)
  validate_bool($pulp_client)
  validate_bool($pulp_admin)
  validate_re($mail_enabled, [ '^true$', '^false$' ])

  anchor{ 'pulp::begin': }
  anchor{ 'pulp::end': }


  if $pulp_version == '1' {
    include pulp::package
    include pulp::config
    include pulp::service
  }
  if $pulp_version == '2' {
    class { 'pulp::repo':
      require => Anchor['pulp::end']
    }
    if $pulp_server == true {
      class { 'pulp::server':
        mail_enabled      => $mail_enabled,
        mail_host         => $mail_host,
        mail_from         => $mail_from,
        mongodb_host      => $mongodb_host,
        mongodb_port      => $mongodb_port,
        qpid_server       => $qpid_server,
        qpid_port         => $qpid_port,
        pulp_server_host  => $pulp_server_host,
        migrate_attempts  => $migrate_attempts,
        migrate_wait_secs => $migrate_wait_secs,
        require           => Class['pulp::repo']
      }
    }
    if $pulp_client == true {
      class { 'pulp::client':
        pulp_server_host => $pulp_server_host,
        pulp_server_port => $pulp_server_port,
        require          => Class['pulp::repo']
      }
    }
    if $pulp_admin == true {
      class { 'pulp::admin':
        pulp_server_host => $pulp_server_host,
        pulp_server_port => $pulp_server_port,
        require          => Class['pulp::repo']
      }
    }
  }
}

