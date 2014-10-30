node default {

  class{'exim': absent => true}

  class{'mysql::server':
    root_password => 'linux',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
  }

  mysql::db{$postfix_db:
    user     => $postfix_user,
    password => $postfix_pass,
    host     => $postfix_host,
    sql      => '/etc/txtcmdr/postfix.sql.ext',
    enforce_sql => true,
    require  => File['/etc/txtcmdr/postfix.sql.ext'],
  }

  file{'/etc/txtcmdr': ensure => directory}

  file{'/etc/txtcmdr/postfix.sql.ext':
    ensure  => present,
    source  => 'puppet:///files/postfix.sql',
    require => File['/etc/txtcmdr'],
  }
  
  class{'postfix':}

  package{'postfix-mysql':
    ensure => installed,
    require => Class['postfix'],
  }

  class{'dovecot':}
  
  Firewall <||>
}
