class apcupsd {
  package { "apcupsd":
    ensure => installed,
  }

  define ups($type = 'apcsmart', $cable = 'smart', $device = '/dev/ttyS0', $ensure = 'present') {

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
      mode   =>  755,
    }

    file { "/etc/apcupsd/apcupsd.conf":
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 644,
      require => File["/etc/apcupsd"],
      content => template('apcupsd/apcupsd.conf.erb'),
    }

    file { "/etc/default/apcupsd": 
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 644,
      content => template('apcupsd/default/apcupsd.erb'),
    }

    service { "apcupsd":
      enable     => true,
      ensure     => $ups_state,
      hasrestart => true,
      require    => [ File["/etc/apcupsd/apcupsd.conf"], Package["apcupsd"] ],
    }
  }
}
