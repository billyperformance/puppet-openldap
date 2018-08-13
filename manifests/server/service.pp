# See README.md for details.
class openldap::server::service {

  if ! defined(Class['openldap::server']) {
    fail 'class ::openldap::server has not been evaluated'
  }

  $ensure = $::openldap::server::start ? {
    true    => running,
    default => stopped,
  }

  #if $::operatingsystem == 'Debian' and versioncmp($::operatingsystemmajrelease, '8') >= 0 {
  #  # Puppet4 fallback to init provider which does not support enableable
  #  $provider = 'debian'
  #} else {
  #  $provider = undef
  #}

  $service_name = $::openldap::server::service

  file { "/etc/systemd/system/${service_name}.service":
    ensure  => file,
    content => template("${module_name}/slapd.service.erb"),
  }

  exec { "Reload systemd daemon for new ${service_name} service config":
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    subscribe   => [
      File["/etc/systemd/system/${service_name}.service"],
    ]
  }

  service { "${service_name}":
    ensure    => $ensure,
    enable    => $::openldap::server::enable,
    hasstatus => $::openldap::server::service_hasstatus,
    provider  => 'systemd',
    require   => File["/etc/systemd/system/${service_name}.service"],
    subscribe => Exec["Reload systemd daemon for new ${service_name} service config"],
  }
}
