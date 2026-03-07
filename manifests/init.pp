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
#
# @summary Install daemon acpupsd to communicate with a UPS
#
# @param ensure
#   Set to absent to tell apcupsd that it is not configured and to stop the
#   service.
# @param upstype
#   Type of UPS device being connected to
# @param cable
#   Type of connection used with the UPS
# @param device
#   Device file used for certain types
# @param nisip
#   IP address on which the network information service will listen for
#   connections.
# @param admin
#   User name or email address for service administrator. Mails will be sent to
#   the user or address when the battery needs to be changed.
# @param mail
#   Command used to send emails for battery change alerts.
# @param polltime
#   Interval in seconds between each polls to the UPS.
#
class apcupsd (
  Enum['present', 'absent'] $ensure = 'present',
  String $upstype = 'apcsmart',
  String $cable = 'smart',
  String $device = '/dev/ttyS0',
  String $nisip = '127.0.0.1',
  String $admin = 'root',
  String $mail = 'mail',
  Integer[0] $polltime = 60,
) {
  package { 'apcupsd':
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

  file { '/etc/apcupsd':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/apcupsd/apcupsd.conf':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    notify  => Service['apcupsd'],
    require => File['/etc/apcupsd'],
    content => template('apcupsd/apcupsd.conf.erb'),
  }

  file { '/etc/apcupsd/changeme':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    notify  => Service['apcupsd'],
    require => File['/etc/apcupsd'],
    content => template('apcupsd/changeme.erb'),
  }

  file { '/etc/default/apcupsd':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    notify  => Service['apcupsd'],
    content => template('apcupsd/default/apcupsd.erb'),
  }

  service { 'apcupsd':
    ensure     => $ups_state,
    enable     => true,
    hasrestart => true,
    require    => [File['/etc/apcupsd/apcupsd.conf'], Package['apcupsd']],
  }
}
