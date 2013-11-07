# Copyright 2013 Tom Noonan II (TJNII)
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
class puppet::common {
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
                          
