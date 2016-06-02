# The home is set to null by package
default['openstack-mistral']['home'] = nil
default['openstack-mistral']['etc_dir'] = '/etc/mistral'

default['openstack-mistral']['db_initialize']['enabled'] = false
default['openstack-mistral']['db_initialize']['superuser'] = 'root'
default['openstack-mistral']['db_initialize']['password'] = 'ilikerandompasswords'
default['openstack-mistral']['db_initialize']['allowed_hosts'] = 'localhost'

# rabbitmq
default['openstack-mistral']['db_initialize']['enabled'] = false
default['openstack-mistral']['db_initialize']['superuser'] = 'root'
default['openstack-mistral']['db_initialize']['password'] = 'ilikerandompasswords'
default['openstack-mistral']['db_initialize']['allowed_hosts'] = 'localhost'

# mongodb
default['openstack-mistral']['db_initialize']['enabled'] = false
default['openstack-mistral']['db_initialize']['superuser'] = 'root'
default['openstack-mistral']['db_initialize']['password'] = 'ilikerandompasswords'
default['openstack-mistral']['db_initialize']['allowed_hosts'] = 'localhost'

default['openstack-mistral']['templates']['logfile_source'] = 'logging.conf.erb'
default['openstack-mistral']['templates']['logfile_cookbook'] = 'openstack-mistral'
# default['openstack-mistral']['logfiles_mode']
