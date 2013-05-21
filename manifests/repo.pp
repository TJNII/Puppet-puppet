class puppet::repo {
  case $operatingsystem {
    centos, redhat: {
      file { '/etc/yum.repos.d/puppetlabs.repo':
        path    => '/etc/yum.repos.d/puppetlabs.repo',
        ensure  => file,
        source  => "puppet:///modules/puppet/repo/puppetlabs.repo",
      }
      
      file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs':
        path    => '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs',
        ensure  => file,
        source  => "puppet:///modules/puppet/repo/RPM-GPG-KEY-puppetlabs",
      }
      
    }
    debian: {
      file { '/etc/apt/sources.list.d/puppetlabs.list':
        path    => '/etc/apt/sources.list.d/puppetlabs.list',
        ensure  => file,
        source  => "puppet:///modules/puppet/repo/puppetlabs.list",
      }
      
      file { '/etc/apt/trusted.gpg.d/puppetlabs-keyring.gpg':
        path    => '/etc/apt/trusted.gpg.d/puppetlabs-keyring.gpg',
        ensure  => file,
        source  => "puppet:///modules/puppet/repo/puppetlabs-keyring.gpg",
      }
    }
  }
}
  
