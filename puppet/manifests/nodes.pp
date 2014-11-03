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
  
  class{'postfix':
  }

  package{'postfix-mysql':
    ensure => installed,
    require => Class['postfix'],
  }

  class{'dovecot':
    package => ['dovecot-imapd','dovecot-pop3d','dovecot-mysql','dovecot-managesieved'],
  }

  package{'roundcube':}

  package{'roundcube-plugins':
    require => Package['roundcube'],
  }

  package{'phpmyadmin':
  }

  openssl::certificate::x509{'mailserver':
    ensure       => present,
    country      => 'PH',
    organization => 'Applester Dev\'t. Corporation',
    unit         => 'Computing Division',
    commonname   => $fqdn,
    base_dir     => '/tmp',
    days         => 3650,
  }

  file{'/etc/ssl/private/mailserver.pem':
    ensure => present,
    source => '/tmp/mailserver.key',
    require => Openssl::Certificate::X509['mailserver'],
  }->exec{'rm /tmp/mailserver.key':}

  file{'/etc/ssl/certs/mailserver.pem':
    ensure => present,
    source => '/tmp/mailserver.crt',
    require => Openssl::Certificate::X509['mailserver'],
  }->exec{'rm /tmp/mailserver.crt':}

  Firewall <||>
}
