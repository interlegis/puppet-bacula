#server.pp

class bacula::server (	$clients = [],
			$filesets = [],
			$jobs = [],
			$pools = [],
			$defaultFullPool,
			$defaultDiffPool,
			$defaultIncPool,
			$schedules = [],
			$storages = [],
			$dirname = "$hostname-dir",
			$dirpw,
			$dirport = 9101,
			$dirmaxjobs = 1,
			$sdname = "$hostname-sd",
			$sdport = 9103,
			$sdmaxjobs = 20,
			$monname = "$hostname-mon",
			$monpw,
 			$catalogname = "MyCatalog",
			$catalogdbname = "bacula",
			$catalogdbaddress = "localhost",
			$catalogdbuser = "bacula",
			$catalogdbpw,
			$fdport = 9102,
			$fdpw,
			$fdname = "$hostname-fd",
			$fdmaxjobs = 20,
			$hddrivename = 'HDDrive-0',
			$hddrivebasepath = '/StageBackup',
			$hddrivepath = '/StageBackup/vtapes',
			$hddrivespool = '/StageBackup/spool',
			$hddrivespoolsize = '1G',
			$hddrivevolsize = '20G',
			$autoprune = 'yes',
		 	) {
	
        if ($lsbdistrelease == "lucid") {
        	$baculapkgname="bacula"
	}else{
		$baculapkgname="bacula-server"
        }
 
	$prereqs=[
		$baculapkgname,
		"bacula-console",
	]

	package { $prereqs: ensure => "present"}

	file { "/etc/bacula/bacula-dir.conf":
                owner => root, group => bacula, mode => 644,
                content => template('bacula/server/bacula-dir.conf.erb'),
                require => Package[$baculapkgname],
        }
	file { "/etc/bacula/bacula-sd.conf":
                owner => bacula, group => bacula, mode => 644,
                content => template('bacula/server/bacula-sd.conf.erb'),
                require => Package[$baculapkgname],
        }
	file { "/etc/bacula/bconsole.conf":
                owner => bacula, group => bacula, mode => 644,
                content => template('bacula/server/bconsole.conf.erb'),
                require => Package[$baculapkgname],
        }

	file { "/etc/bacula/conf.d":
		owner => root, group => bacula, mode => 444,
		ensure => "directory",
		require => Package[$baculapkgname],
	}
	file { "/etc/bacula/conf.d/Catalogs.conf":
                owner => bacula, group => bacula, mode => 644,
                content => template('bacula/server/conf.d/Catalogs.conf.erb'),
                require => File["/etc/bacula/conf.d"],
        }
	file { "/etc/bacula/conf.d/Clients.conf":
                owner => bacula, group => bacula, mode => 644,
                content => template('bacula/server/conf.d/Clients.conf.erb'),
                require => File["/etc/bacula/conf.d"],
        }
	file { "/etc/bacula/conf.d/FileSets.conf":
                owner => bacula, group => bacula, mode => 644,
                content => template('bacula/server/conf.d/FileSets.conf.erb'),
                require => File["/etc/bacula/conf.d"],
        }
	file { "/etc/bacula/conf.d/Jobs.conf":
                owner => bacula, group => bacula, mode => 644,
                content => template('bacula/server/conf.d/Jobs.conf.erb'),
                require => File["/etc/bacula/conf.d"],
        }
	file { "/etc/bacula/conf.d/Messages.conf":
                owner => bacula, group => bacula, mode => 644,
                content => template('bacula/server/conf.d/Messages.conf.erb'),
                require => File["/etc/bacula/conf.d"],
        }
	file { "/etc/bacula/conf.d/Monitors.conf":
                owner => bacula, group => bacula, mode => 644,
                content => template('bacula/server/conf.d/Monitors.conf.erb'),
                require => File["/etc/bacula/conf.d"],
        }
	file { "/etc/bacula/conf.d/Pools.conf":
                owner => bacula, group => bacula, mode => 644,
                content => template('bacula/server/conf.d/Pools.conf.erb'),
                require => File["/etc/bacula/conf.d"],
        }
	file { "/etc/bacula/conf.d/Schedules.conf":
                owner => bacula, group => bacula, mode => 644,
                content => template('bacula/server/conf.d/Schedules.conf.erb'),
                require => File["/etc/bacula/conf.d"],
        }
	file { "/etc/bacula/conf.d/Storages.conf":
                owner => bacula, group => bacula, mode => 644,
                content => template('bacula/server/conf.d/Storages.conf.erb'),
                require => File["/etc/bacula/conf.d"],
        }
	

	file { $hddrivebasepath:
                owner => bacula, group => bacula, mode => 644,
                ensure => directory,
		require => Package[$baculapkgname],
        }
	file { $hddrivepath:
                #owner => bacula, group => tape, mode => 644,
                ensure => directory,
		require => File[$hddrivebasepath],
        }

	file { $hddrivespool:
                owner => bacula, group => bacula, mode => 644,
		recurse => true,
                ensure => directory,
		require => File[$hddrivebasepath],
        }

	file { "/var/run/bacula":
		owner => bacula, group => daemon, mode => 644,
		recurse => true,
	}

	service { "bacula-sd":
		enable => true,
		ensure => running,
		status => "/etc/init.d/bacula-sd status",
		subscribe => [
			File["/etc/bacula/bacula-sd.conf"],
			File["/etc/bacula/conf.d/Catalogs.conf"],
			File["/etc/bacula/conf.d/Clients.conf"],
			File["/etc/bacula/conf.d/FileSets.conf"],
			File["/etc/bacula/conf.d/Jobs.conf"],
			File["/etc/bacula/conf.d/Messages.conf"],
			File["/etc/bacula/conf.d/Monitors.conf"],
			File["/etc/bacula/conf.d/Pools.conf"],
			File["/etc/bacula/conf.d/Schedules.conf"],
			File["/etc/bacula/conf.d/Storages.conf"],
		],
		require => File["/var/run/bacula"],
	}
	service { "bacula-director":
		enable => true,
		ensure => running,
		status => "/etc/init.d/bacula-director status",
		subscribe => [
			File["/etc/bacula/bacula-dir.conf"],
                        File["/etc/bacula/conf.d/Catalogs.conf"],
                        File["/etc/bacula/conf.d/Clients.conf"],
                        File["/etc/bacula/conf.d/FileSets.conf"],
                        File["/etc/bacula/conf.d/Jobs.conf"],
                        File["/etc/bacula/conf.d/Messages.conf"],
                        File["/etc/bacula/conf.d/Monitors.conf"],
                        File["/etc/bacula/conf.d/Pools.conf"],
                        File["/etc/bacula/conf.d/Schedules.conf"],
                        File["/etc/bacula/conf.d/Storages.conf"],
                ],
		require => [
			Service["bacula-sd"],
			File["/var/run/bacula"],
		],
	}

	notify {"Lembre-se de configurar a base de dados do MySQL com o comando: dpkg-reconfigure bacula-director-mysql!":
		require => Package[$prereqs],
	}

}
