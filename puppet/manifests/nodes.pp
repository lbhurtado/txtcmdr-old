node default {

  class { 'mysql::server':
    root_password => 'linux',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
  }

  class { 'mysql::bindings': php_enable => true }
  package { 'phpmyadmin':
    ensure => 'installed',
    require => [Class['php'], Class['mysql::server']]
  }
  mysql::db { $postfix_db:
    user     => $postfix_user,
    password => $postfix_pass,
    host     => $postfix_host,
    sql      => '/tmp/postfix.sql',
    require  => File['/tmp/postfix.sql'],
  }

  file { '/tmp/postfix.sql':
    ensure => present,
    source => 'puppet:///files/postfix.sql',
  }

  /*
  class { 'resolver':
    dns_servers => ['172.16.0.2'],
  }

  class { 'bind': }

  bind::zone { 'txtcmdr.xyz':
    zone_type => 'master',
    zone_ns => 'txtcmdr.xyz.',
    zone_contact => 'root.txtcmdr.xyz.',
    zone_ttl => 604800,
    zone_serial => 2,
  }

  bind::ns { 'txtcmdr.xyz.':
    zone   => 'txtcmdr.xyz',
  }

  bind::mx { 'mail':
    zone   => 'txtcmdr.xyz',
    record_priority => 10,
  }

  bind::a { ' ':
    zone   => 'txtcmdr.xyz',
    target => '172.16.0.2',
  }

  bind::a { 'www':
    zone   => 'txtcmdr.xyz',
    target => '172.16.0.2',
  }
*/

  class { 'postfix':

  }

  package { 'postfix-mysql':
    require => Class['postfix'],
  }

  /*
  class { 'postfix::mastercf':
    source => 'puppet:///files/master.cf',
  }

  package { 'postfix-mysql':
    require => Class['postfix'],
  }

  file { '/etc/postfix/mysql-virtual-mailbox-domains.cf':
    ensure => present,
    source => 'puppet:///files/mysql-virtual-mailbox-domains.cf',
    notify => Class['postfix'],
  }

  file { '/etc/postfix/mysql-virtual-mailbox-maps.cf':
    ensure => present,
    source => 'puppet:///files/mysql-virtual-mailbox-maps.cf',
    notify => Class['postfix'],
  }

  file { '/etc/postfix/mysql-virtual-alias-maps.cf':
    ensure => present,
    source => 'puppet:///files/mysql-virtual-alias-maps.cf',
    notify => Class['postfix'],
  }
  */

  Firewall <||>
}
