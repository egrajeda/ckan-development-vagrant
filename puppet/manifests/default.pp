include apt

package { ["build-essential", "python-dev", "python-pip", "libpq-dev", "solr-tomcat"]:
    ensure  => "installed",
    require => Exec["apt_update"]
}

class { 'postgresql::server':
    listen_addresses        => '*',
    ip_mask_allow_all_users => '0.0.0.0/0'
}

postgresql::server::db { ['ckan_default', 'datastore_default', 'ckan_test', 'datastore_test']:
    user     => 'ckan_default',
    password => postgresql_password('ckan_default', 'test1234')
}

postgresql::server::role { 'datastore_default':
    password_hash => postgresql_password('datastore_default', 'test1234')
}

postgresql::server::database_grant { ['datastore_default', 'datastore_test']:
    privilege => 'ALL',
    db        => 'datastore_default',
    role      => 'datastore_default'
}

file { '/etc/solr/conf/schema.xml':
    ensure => 'link',
    target => '/ckan/ckan/config/solr/schema.xml',
    require => Package["solr-tomcat"]
}

exec { "ckan-pip-requirements":
    command => "/usr/bin/pip install -r /ckan/requirements.txt -r /ckan/dev-requirements.txt",
    timeout => 1800,
    tries   => 5,
    require => Package["python-pip"]
}

exec { "ckan-setup":
    command => "/usr/bin/python setup.py develop",
    cwd     => "/ckan",
    require => Exec["ckan-pip-requirements"]
}

package { ["python-lxml"]:
    ensure  => "installed",
    require => Exec["apt_update"]
}

exec { "ckan-datapusher-pip-requirements":
    command => "/usr/bin/pip install -r /ckan-datapusher/requirements.txt",
    timeout => 1800,
    tries   => 5,
    require => Package["python-pip"]
}

exec { "ckan-datapusher-setup":
    command => "/usr/bin/python setup.py develop",
    cwd     => "/ckan-datapusher",
    require => Exec["ckan-datapusher-pip-requirements"]
}

class database_setup {

    exec { "ckan-database-setup":
        command => "/usr/local/bin/paster db init -c development.ini",
        cwd     => "/ckan",
        require => Exec["ckan-pip-requirements"]
    }

    exec { "ckan-datastore-permissions-sql":
        command => "/usr/local/bin/paster datastore set-permissions > /tmp/datastore-permissions.sql",
        cwd     => "/ckan",
        require => Exec["ckan-pip-requirements"]
    }

    postgresql_psql { "ckan-datastore-set-permissions":
        command => "\\i datastore-permissions.sql",
        require => Exec["ckan-datastore-permissions-sql"]
    }

}

stage { 'post':
    require => Stage['main']
}

class { 'database_setup':
    stage => 'post'
}
