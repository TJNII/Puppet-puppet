class puppet::server( $manage_firewall = true ) {
  class {'puppet::repo': }
  
  case $operatingsystem {
    centos, redhat: {
      package { ['puppet', 'puppet-server', 'puppetdb']:
	ensure  => installed,
	require => [File['/etc/yum.repos.d/puppetlabs.repo'], File['/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs']]
      }

      service { 'puppet':
	name      => 'puppet',
	ensure    => running,
	enable    => true,
	subscribe => File['/etc/puppet/puppet.conf'],
      }
      
    }
    debian: {
      package { ['puppet', 'puppetmaster', 'puppetdb', 'puppetdb-terminus', 'puppet-el', 'ruby-elisp']:
	ensure  => installed,
      }
      
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
    source  => "puppet:///modules/puppet/puppet.server.conf",
  }

  file { '/etc/puppet/auth.conf':
    path    => '/etc/puppet/auth.conf',
    ensure  => file,
    require => Package['puppet'],
    source  => "puppet:///modules/puppet/auth.server.conf",
  }
  
  service { 'puppetmaster':
    name      => 'puppetmaster',
    ensure    => running,
    enable    => true,
    subscribe => [File['/etc/puppet/puppet.conf'], File['/etc/puppet/auth.conf']]
  }

  service { 'puppetdb':
    name      => 'puppetdb',
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/puppet/puppetdb.conf'],
  }
  
  file { '/etc/puppet/puppetdb.conf':
    path    => '/etc/puppet/puppetdb.conf',
    ensure  => file,
    require => Package['puppetdb'],
    source  => "puppet:///modules/puppet/puppetdb.server.conf",
  }

  if $manage_firewall == true {
    include firewall-config::base
    
    firewall { '100 allow puppetmaster:8140':
      state => ['NEW'],
      dport => '8140',
      proto => 'tcp',
      action => accept,
    }
  }
}
