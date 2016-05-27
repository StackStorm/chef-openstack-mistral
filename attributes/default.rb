default['openstack-mistral']['repo']['home'] = '/opt/stackstorm/mistral'

# The actual home is set by the install recipe
default['openstack-mistral']['home'] = nil
default['openstack-mistral']['etc_dir'] = '/opt/stackstorm/mistral/etc'
default['openstack-mistral']['db_initialize']['enabled'] = false
default['openstack-mistral']['db_initialize']['superuser'] = 'root'
default['openstack-mistral']['db_initialize']['password'] = 'ilikerandompasswords'
default['openstack-mistral']['db_initialize']['allowed_hosts'] = 'localhost'

default['openstack-mistral']['templates']['logfile_source'] = 'logging.conf.erb'
default['openstack-mistral']['templates']['logfile_cookbook'] = 'openstack-mistral'
# default['openstack-mistral']['logfiles_mode']
