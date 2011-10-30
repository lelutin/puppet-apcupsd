# This module is distributed under the GNU Affero General Public License:
# 
# Apcupsd module for puppet
# Copyright (C) 2010 Sarava Group
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class apcupsd(
  $upstype = 'apcsmart',
  $cable = 'smart',
  $device = '/dev/ttyS0',
  $ensure = 'present',
  $nisip = '127.0.0.1',
  $polltime = '60' )
{

  package { "apcupsd":
    ensure => installed,
  }

  $ups_configured = $ensure ? {
    'present' => 'yes',
    'absent'  => 'no',
  }

  $ups_state = $ensure ? {
    'present' => 'running',
    'absent'  => 'stopped',
  }

  file { "/etc/apcupsd":
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   =>  0755,
  }

  file { "/etc/apcupsd/apcupsd.conf":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0644,
    notify  => Service["apcupsd"],
    require => File["/etc/apcupsd"],
    content => template('apcupsd/apcupsd.conf.erb'),
  }

  file { "/etc/default/apcupsd":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0644,
    notify  => Service["apcupsd"],
    content => template('apcupsd/default/apcupsd.erb'),
  }

  service { "apcupsd":
    enable     => true,
    ensure     => $ups_state,
    hasrestart => true,
    require    => [ File["/etc/apcupsd/apcupsd.conf"], Package["apcupsd"] ],
  }
}
