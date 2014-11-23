node default {

  class{'txtcmdr':}

  class{'txtcmdr::noexim':}

  class{'mysql::server':
    root_password => 'linux',
    require => Class['txtcmdr'],
  }

  class{'txtcmdr::postfix':
    require => Class['mysql::server'],
  }

  class{'txtcmdr::secure':}
  
  class{'txtcmdr::dovecot':}

/*
  package{'roundcube':}
  package{'roundcube-plugins':
    require => Package['roundcube'],
  }
  package{'phpmyadmin':}
*/

  Firewall <||>

/*  
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
*/
}
