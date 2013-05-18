class puppet::server( $manage_firewall = true ) {
   case $operatingsystem {
      centos, redhat: {
         # Puppet repository files for puppetdb
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
         # TODO: Ensure puppetlabs repo is installed
	 package { ['puppet', 'puppetmaster', 'puppetdb', 'puppetdb-terminus']:
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
  
  service { 'puppetmaster':
    name      => 'puppetmaster',
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/puppet/puppet.conf'],
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
