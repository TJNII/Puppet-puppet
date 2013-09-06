class puppet::client (
  $agent_puppetmaster_fqdn = "puppetmaster.tjnii.com",
  ) {
    class {'puppet::common': }
    
    # Do not include master block in puppet.conf
    $is_master    = false
    
    file { '/etc/puppet/puppet.conf':
      path    => '/etc/puppet/puppet.conf',
      ensure  => file,
      require => Package['puppet'],
      content => template("puppet/puppet.conf.erb"),
    }
    
  }
                          
