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
class puppet::repo {
  case $operatingsystem {
    centos, redhat: {
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
      
    }
    debian: {
      file { '/etc/apt/sources.list.d/puppetlabs.list':
        path    => '/etc/apt/sources.list.d/puppetlabs.list',
        ensure  => file,
        source  => "puppet:///modules/puppet/repo/puppetlabs.list",
      }
      
      file { '/etc/apt/trusted.gpg.d/puppetlabs-keyring.gpg':
        path    => '/etc/apt/trusted.gpg.d/puppetlabs-keyring.gpg',
        ensure  => file,
        source  => "puppet:///modules/puppet/repo/puppetlabs-keyring.gpg",
      }
    }
  }
}
  
