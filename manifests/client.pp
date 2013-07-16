class puppet::client {
  class {'puppet::common': }

  $puppetmaster = "puppetmaster.tjnii.com"
  
  file { '/etc/puppet/puppet.conf':
    path    => '/etc/puppet/puppet.conf',
    ensure  => file,
    require => Package['puppet'],
    content => template("puppet/puppet.client.conf.erb"),
  }

}
                          
