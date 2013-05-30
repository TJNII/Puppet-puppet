class puppet::common {
  # Ensure the puppetlabs repo is installed
  class {'puppet::repo': }
  
  # This is redundant, because you can't run this without puppet...
  package { 'puppet':
    ensure => latest,
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

  # Fix some permissions on /var/lib/puppet for Nagios and general use
  # Allow anyone to get into /var/lib/puppet
  file { '/var/lib/puppet':
    ensure  => directory,
    mode    => 755,
    require => Package['puppet'],
  }

  # And allow reading of state
  # (This is largely fixing a goof below...)
  file { '/var/lib/puppet/state':
    ensure  => directory,
    mode    => 1755,
    require => Package['puppet'],
  }

  # But restrict the non-state directories
  file { ['/var/lib/puppet/clientbucket',
    '/var/lib/puppet/client_data',
    '/var/lib/puppet/client_yaml',
    '/var/lib/puppet/facts']:
    ensure  => directory,
    mode    => 750,
    require => Package['puppet'],
  }

  # lib and ssl both conflict with other puppet modules / code and have sensible defaults
    
}
                          
