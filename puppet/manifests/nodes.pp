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

  Firewall <||>

}
