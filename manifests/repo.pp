# Class pulp::repo
#
class pulp::repo (
  $repo_enabled = true
){
  if $repo_enabled == true {
    yumrepo {'rhel-pulp':
      name     => 'pulp-v2-stable',
      descr    => 'Pulp Community Releases',
      baseurl  => 'http://repos.fedorapeople.org/repos/pulp/pulp/v2/stable/6Server/$basearch/',
      enabled  => '1',
      gpgcheck => '0',
    }
  }
}
