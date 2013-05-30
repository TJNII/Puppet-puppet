class puppet::client {
  class {'puppet::common': }
  
  file { '/etc/puppet/puppet.conf':
    path    => '/etc/puppet/puppet.conf',
    ensure  => file,
    require => Package['puppet'],
    source  => "puppet:///modules/puppet/puppet.client.conf",
  }

}
                          
