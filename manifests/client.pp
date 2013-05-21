class puppet::client {
  # Ensure the puppetlabs repo is installed
  class {'puppet::repo': }
  
  # This is redundant, because you can't run this without puppet...
  package { 'puppet':
    ensure => installed,
  }
  
  case $operatingsystem {
      centos, redhat: {
         service { 'puppet':
            name      => 'puppet',
            ensure    => running,
            enable    => true,
            subscribe => File['/etc/puppet/puppet.conf'],
         }

      }
      debian: {
         service { 'puppet':
            name      => 'puppet',
            ensure    => running,
            enable    => true,
            subscribe => [File['/etc/puppet/puppet.conf'], File['/etc/default/puppet']],
         }

         file { '/etc/default/puppet':
            path    => '/etc/default/puppet',
            ensure  => file,
            require => Package['puppet'],
            source  => "puppet:///modules/puppet/puppet.defaults.debian",
         }
      }
  }

  file { '/etc/puppet/puppet.conf':
    path    => '/etc/puppet/puppet.conf',
    ensure  => file,
    require => Package['puppet'],
    source  => "puppet:///modules/puppet/puppet.client.conf",
  }

}
                          
