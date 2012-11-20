# Class pulp::client
class pulp::client (
  $pulp_server_host = undef,
  $pulp_server_port = '443'
) inherits pulp::params {
  require pulp::repo
  $packagelist = ['pulp-rpm-consumer-client','pulp-rpm-agent']
  package { $packagelist:
    ensure  => 'installed',
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
