#client.pp

class bacula::client (	$dirname,
			$monname,
  			$monpw,
  			$fdname = "$hostname-fd",
			$fdpw,
			$fdport = 9102,
			$fdmaxjobs = 20,
	) {

        package { "bacula-fd": ensure => "present" }
        file { "/etc/bacula/bacula-fd.conf":
                owner => root, group => root, mode => 640,
                content => template('bacula/bacula-fd.conf.erb'),
                require => Package['bacula-fd'],
        }

        service { "bacula-fd":
                ensure => running,
                enable => true,
                hasstatus => true,
                require => [
                        Package["bacula-fd"],
                        File["/etc/bacula/bacula-fd.conf"],
                ],
                subscribe => File["/etc/bacula/bacula-fd.conf"],
        }

}

