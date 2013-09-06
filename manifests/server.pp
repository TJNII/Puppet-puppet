class puppet::server(
  $manage_firewall = true,
  $agent_puppetmaster_fqdn = $fqdn,
  $independent_agent = false,
  ) {
    class {'puppet::common': }
    
    # Include master block in puppet.conf
    $is_master = true

    # Split master var directory for master instances independent from the agent
    if $independent_agent == false {
      $masterdir = "puppet"
    } else {
      $masterdir = "puppetmaster"

      # Allow anyone to get into /var/lib/puppet
      file { "/var/lib/$masterdir":
        ensure  => directory,
        mode    => 755,
        require => Package['puppet'],
        owner    => 'puppet',
        group   => 'puppet',
      }
      
      # And allow reading of state
      file { "/var/lib/$masterdir/state":
        ensure  => directory,
        mode    => 1755,
        require => Package['puppet'],
        owner    => 'puppet',
        group   => 'puppet',
      }
      
      # But restrict the non-state directories
      file { ["/var/lib/$masterdir/clientbucket",
              "/var/lib/$masterdir/client_data",
              "/var/lib/$masterdir/client_yaml",
              "/var/lib/$masterdir/facts"]:
                ensure  => directory,
                mode    => 750,
                require => Package['puppet'],
      }

      # PuppetDB CA Fix-o-matic
      file { "/usr/sbin/puppetdb-autofix-ssl":
        ensure  => file,
        source  => "puppet:///modules/puppet/puppetdb-autofix-ssl",
        mode    => 755,
      }

      # Requires gurrent openSSL, Puppet doesn't have >version functionality
      exec { "puppetdb-autofix-ssl":
        # This script is idempotent.
        command     => "/usr/sbin/puppetdb-autofix-ssl $fqdn",
        cwd         => "/tmp",
        require     => [ File['/usr/sbin/puppetdb-autofix-ssl'],
                         File['/usr/sbin/puppetdb-ssl-setup-answers.txt'],
                         Service['puppetdb'],
                         Service["puppetmaster"],
                         ],
      }      
    }

    # Seed the PuppetDB SSL generation tool
    file { '/usr/sbin/puppetdb-ssl-setup-answers.txt':
      ensure  => file,
      content => template("puppet/puppetdb-ssl-setup-answers.txt.erb"),
      mode    => 644,
    }

    case $operatingsystem {
      centos, redhat: {
        package { 'puppet-server':
	  ensure  => installed,
	  require => [ File['/etc/yum.repos.d/puppetlabs.repo'],
                       File['/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs'],
                       File['/usr/sbin/puppetdb-ssl-setup-answers.txt'],
                       File['/etc/puppet/puppet.conf'],
                       File["/var/lib/$masterdir"],
                       ],
        }
        
      }
      debian: {
        package { ['puppetmaster', 'puppetdb-terminus', 'puppet-el' ]:
	  ensure  => installed,
          require => [ File['/usr/sbin/puppetdb-ssl-setup-answers.txt'],
                       File['/etc/puppet/puppet.conf'],
                       File["/var/lib/$masterdir"],
                       ],
        }
        
        case $operatingsystemmajrelease {
          6: {
            # Not in Wheezy (yet?)
            package { 'ruby-elisp':
              ensure  => installed,
            }
          }
        }     
      }
    }

    package { 'puppetdb':
      ensure  => installed,
      require => [ File['/usr/sbin/puppetdb-ssl-setup-answers.txt'],
                   File['/etc/puppet/puppet.conf'],
                   File["/var/lib/$masterdir"],
                   # For CA
                   Service["puppetmaster"],
                   ],
    }

    file { '/etc/puppet/puppet.conf':
      path    => '/etc/puppet/puppet.conf',
      ensure  => file,
      require => Package['puppet'],
      content => template("puppet/puppet.conf.erb"),
    }
    
    file { '/etc/puppet/auth.conf':
      path    => '/etc/puppet/auth.conf',
      ensure  => file,
      require => Package['puppet'],
      content => template("puppet/auth.server.conf.erb"),
    }
    
    service { 'puppetmaster':
      name      => 'puppetmaster',
      ensure    => running,
      enable    => true,
      subscribe => [ File['/etc/puppet/puppet.conf'],
                     File['/etc/puppet/auth.conf'],
                     File["/var/lib/$masterdir/state"],
                     ]
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
      content => template("puppet/puppetdb.server.conf.erb"),
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

    file { "/etc/cron.daily/puppet-clean-reports":
      ensure  => file,
      source  => "puppet:///modules/puppet/puppet-clean-reports",
      mode    => 755,
    }

  }
  
