# = Class: pulp
#
# == This module manages pulp
#
# == Parameters
#
# [*pulp_version*]
#   Version of stable pulp to install either '1' or '2'.
#   The default is to install Pulp Project version '1'.
#
# [*pulp_server*]
#   Install the pulp server as long as pulp_version is set to '2'.
#
# [*pulp_client*]
#   Install the pulp client as long as pulp_version is set to '2'.
#
# [*pulp_admin*]
#   Install the pulp admin tool as long as pulp_version is set to '2'.
#
# [*pulp_server_host*]
#   Hostname of pulp server.
#
# [*pulp_server_port*]
#   TCP/IP port of pulp server.
#
#  [*repo_enabled*]
#    Enable pulp yum repository.
#
# [*mail_enabled*]
#   Allow pulp to send outgoing email.
#
# [*mail_host*]
#   Hostname of email server.
#
# [*mail_host_port*]
#   Email server TCP/IP port.
#
# [*mail_from*]
#   From email address of pulp administrator.
#
# [*mongodb_host*]
#   MongoDB server hostname or ip address.
#
# [*mongodb_port*]
#   TCP/IP port for MongoDB host.
#
# [*qpid_server*]
#   Apache Qpid AMQP host.
#
# [*qpid_port*]
#   TCP/IP port for AMQP host.
#
# [*migrate_attempts*]
#   Number of attempts to execute pulp-manage-db successfully.
#
# [*migrate_wait_secs*]
#   Number of seconds to wait between pulp-manage-db attempts.
#
# [*package_version*]
#   Set installation version e.g. 2.1.0, installed or latest.
#   Current supported under pulp v2 only.
#
# == Actions
#
# == Requires
#
# puppetlab/puppetlabs-stdlib
#
# == Sample Usage
#
# Install pulp server v.1:
#
# include pulp
#
# Install pulp server v.2:
#
# class { 'pulp':
#   pulp_version => '2',
#   pulp_server  => true
# }
#
# Install pulp client v.2:
#
# class { 'pulp':
#   pulp_version => '2',
#   pulp_client  => true
# }
#
# Install pulp server with admin client v.2 and repository enabled:
#
# class { 'pulp':
#   pulp_version => '2',
#   pulp_server  => true,
#   pulp_admin   => true,
#   repo_enabled => true
# }
#
# == Todo
#
#  * Add pulp version 1. repo
#  * Add README.md content
#
class pulp (
  $pulp_version      = '1',
  $pulp_server       = false,
  $pulp_client       = false,
  $pulp_admin        = false,
  $pulp_server_host  = 'localhost.localdomain',
  $pulp_server_port  = '443',
  $repo_enabled      = false,
  $mail_enabled      = 'false',
  $mail_host         = 'localhost.localdomain',
  $mail_host_port    = '25',
  $mail_from         = undef,
  $mongodb_host      = 'localhost.localdomain',
  $mongodb_port      = '27017',
  $qpid_server       = 'localhost.localdomain',
  $qpid_port         = '5672',
  $migrate_attempts  = '3',
  $migrate_wait_secs = '5',
  $package_version   = 'installed'
) {

  #Validation
  validate_re($pulp_version, '^[1-2]$')
  validate_bool($pulp_server)
  validate_bool($pulp_client)
  validate_bool($pulp_admin)
  validate_bool($repo_enabled)
  validate_re($package_version, ['^installed$', '^latest$', '^2\.'])
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
      repo_enabled => $repo_enabled,
      require      => Anchor['pulp::end']
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
        package_version   => $package_version,
        require           => Class['pulp::repo']
      }
    }
    if $pulp_client == true {
      class { 'pulp::client':
        pulp_server_host => $pulp_server_host,
        pulp_server_port => $pulp_server_port,
        package_version  => $package_version,
        require          => Class['pulp::repo']
      }
    }
    if $pulp_admin == true {
      class { 'pulp::admin':
        pulp_server_host => $pulp_server_host,
        pulp_server_port => $pulp_server_port,
        package_version  => $package_version,
        require          => Class['pulp::repo']
      }
    }
  }
}

