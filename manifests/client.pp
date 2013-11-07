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
class puppet::client (
  $agent_puppetmaster_fqdn,
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

    # Workaround for bug #20607
    file { '/var/lib/puppet/state/last_run_summary.yaml':
      ensure  => file,
      require => Package['puppet'],
    }
  }
                          
