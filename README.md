# Puppet Module for [Pulp: Juicy Software Repository Management](http://www.pulpproject.org/)

[![Build Status](https://travis-ci.org/KrisBuytaert/puppet-pulp.png)](https://travis-ci.org/KrisBuytaert/puppet-pulp)

Pulp is a platform for managing repositories of content, such as software packages, and pushing that content out to large numbers of consumers.

This puppet module is for installing and configuring it.

## Usage

### Installing Pulp Server Version 1

default:
```puppet
include pulp
```

### Installing Pulp Version 2

pulp server:
```puppet
class { 'pulp':
    pulp_version => '2',
    pulp_server  => true
}
```

pulp client:
```puppet
class { 'pulp':
    pulp_version => '2',
    pulp_client  => true
}
```

pulp server with admin client and yum repository enabled:
```puppet
class { 'pulp':
    pulp_version => '2',
    pulp_server  => true,
    pulp_admin   => true,
    repo_enabled => true
}
```

