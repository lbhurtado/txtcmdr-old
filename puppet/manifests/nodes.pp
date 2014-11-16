node default {

  class{'txtcmdr':}

  class{'exim': absent => true}

  class{'mysql::server':
    root_password => 'linux',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
    require => Class['txtcmdr'],
  }

  mysql::db{$postfix_db:
    user     => $postfix_user,
    password => $postfix_pass,
    host     => $postfix_host,
    grant    => ['SELECT'],
    sql      => $txtcmdr::postfix_db_init_sql,
    enforce_sql => true,
  }

  class{'postfix':
    require => Class['txtcmdr'],
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
  ->  
  postfix::postconf{'virtual_mailbox_domains':
    value => "${postfix::config_dir}/mysql-virtual-mailbox-domains.cf"
  }

  postfix::map{'mysql-virtual-mailbox-maps.cf':
    maps => {
      user => $postfix_user,
      password => $postfix_pass,
      hosts => '127.0.0.1',
      dbname => $postfix_db,
      query => 'select 1 from virtual_users where email=\'%s\''
    },
  }
  ->
  postfix::postconf{'virtual_mailbox_maps':
    value => "${postfix::config_dir}/mysql-virtual-mailbox-maps.cf"
  }

  postfix::map{'mysql-virtual-alias-maps.cf':
    maps => {
      user => $postfix_user,
      password => $postfix_pass,
      hosts => '127.0.0.1',
      dbname => $postfix_db,
      query => 'select 1 from virtual_aliases where source=\'%s\''
    },
  }
  ->
  postfix::postconf{'virtual_alias_maps':
    value => "${postfix::config_dir}/mysql-virtual-alias-maps.cf"
  }


  package{'postfix-mysql':
    ensure => installed,
    require => Class['postfix'],
  }

  group{'vmail': gid => 5000}
 
  user{'vmail':
    ensure     => present,
    uid        => 5000,
    gid        => 'vmail',
    home       => '/var/vmail',
    managehome => true,
  }

  package{'roundcube':}

  package{'roundcube-plugins':
    require => Package['roundcube'],
  }

  package{'phpmyadmin':}

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
    ensure  => present,
    source  => '/tmp/mailserver.key',
    require => Openssl::Certificate::X509['mailserver'],
  }
  ->
  exec{'rm /tmp/mailserver.key':}

  file{'/etc/ssl/certs/mailserver.pem':
    ensure  => present,
    source  => '/tmp/mailserver.crt',
    require => Openssl::Certificate::X509['mailserver'],
  }
  ->
  exec{'rm /tmp/mailserver.crt':}

  Firewall <||>
  
  class{'dovecot':
    config_file_group => 'vmail',
    config_file_mode  => 'g+r',
    package    => ['dovecot-imapd','dovecot-pop3d','dovecot-mysql','dovecot-managesieved'],
    source_dir => 'puppet:///modules/txtcmdr/dovecot',
    require    => [Class['txtcmdr'],File['/etc/ssl/private/mailserver.pem'],File['/etc/ssl/certs/mailserver.pem']],
  }
  
  file{'/etc/dovecot/dovecot-sql.conf.ext':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 'go=',    
    require => Class['dovecot'],
  }
  
  class { 'postfix::mastercf':
    source => 'puppet:///modules/txtcmdr/master.cf',
    require => Class['txtcmdr'],
  }
  ->
  postfix::postconf{'virtual_transport':
    value => 'dovecot',
  }
  ->
  postfix::postconf{'dovecot_destination_recipient_limit':
    value => '1',
  }

}
