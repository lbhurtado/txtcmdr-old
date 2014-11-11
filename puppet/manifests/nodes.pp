node default {

  class{'exim': absent => true}

  class{'mysql::server':
    root_password => 'linux',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
  }

  txtcmdr::popsql{'postfix.sql':}

  include txtcmdr::params

  mysql::db{$postfix_db:
    user     => $postfix_user,
    password => $postfix_pass,
    host     => $postfix_host,
    grant    => ['SELECT'],
    sql      => "${txtcmdr::params::config_dir}/postfix.sql",
    enforce_sql => true,
    require  => Txtcmdr::Popsql['postfix.sql'],
  }

  class{'postfix':}

  class{'txtcmdr':
  }
/* 
  txtcmdr::postfix::maptemplate{'map.erb':}

  postfix::map{'mysql-virtual-mailbox-domains.cf':
    maps => {
      user => $postfix_user,
      password => $postfix_pass,
      hosts => '127.0.0.1',
      dbname => $postfix_db,
      query => 'select 1 from virtual_domains where name=\'%s\''
    },
    template => '/etc/txtcmdr/map.erb',
    require => Txtcmdr::Postfix::Maptemplate['map.erb'], 
  }

  postfix::postconf{'virtual_mailbox_domains':
    value => "${postfix::config_dir}/mysql-virtual-mailbox-domains.cf"
  }
*/
/*
  postfix::map{'mysql-virtual-mailbox-users.cf':
    maps => {
      user => $postfix_user,
      password => $postfix_pass,
      hosts => '127.0.0.1',
      dbname => $postfix_db,
      query => 'select 1 from virtual_users where email=\'%s\''
    },
    template => 'puppet:///modules/txtcmdr/map.erb',
    require => Class['txtcmdr'], 
  }

  postfix::postconf{'virtual_mailbox_users':
    value => "${postfix::config_dir}/mysql-virtual-mailbox-users.cf"
  }
*/
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
