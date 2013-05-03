# Class pulp::client
class pulp::client (
  $pulp_server_host = undef,
  $pulp_server_port = '443',
  $package_version   = 'installed'
) {
  $packagelist = ['pulp-agent', 'pulp-consumer-client','pulp-puppet-handlers', 'pulp-rpm-consumer-extensions', 'pulp-rpm-handlers']
  package { $packagelist:
    ensure  => $package_version,
  }
  file { '/etc/pulp/consumer/consumer.conf':
    ensure  => 'file',
    content => template('pulp/consumer.conf.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package[$packagelist],
    notify  => Service['goferd'],
  }
  service {'goferd':
    ensure  => 'running',
    enable  => 'true',
  }
}
