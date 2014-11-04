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
    grant    => ['SELECT'],
    sql      => '/etc/txtcmdr/postfix.sql',
    enforce_sql => true,
    require  => File['/etc/txtcmdr/postfix.sql'],
  }

  file{'/etc/txtcmdr': ensure => directory}

  file{'/etc/txtcmdr/postfix.sql':
    ensure  => present,
    source  => 'puppet:///modules/txtcmdr/postfix/postfix.sql',
    require => File['/etc/txtcmdr'],
  }
  
  class{'postfix':}

  file{'/tmp/map.erb':
    ensure  => present,
    source  => 'puppet:///modules/txtcmdr/postfix/map.erb',
  }
  
  postfix::map{'mysql-virtual-mailbox-domains.cf':
    maps => {
      user => $postfix_user,
      password => $postfix_pass,
      hosts => '127.0.0.1',
      dbname => $postfix_db,
      query => 'select 1 from virtual_domains where name=\'%s\''
    },
  }

  postfix::postconf{'virtual_mailbox_domains':
    value => "${postfix::config_dir}/mysql-virtual-mailbox-domains.cf"
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
