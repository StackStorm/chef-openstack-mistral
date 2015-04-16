default['openstack-mistral']['install_recipe'] = 'openstack-mistral::install_source'

default['openstack-mistral']['source']['git_url'] = 'https://github.com/stackforge/mistral'
default['openstack-mistral']['source']['git_revision'] = nil
default['openstack-mistral']['source']['git_action']   = nil
default['openstack-mistral']['source']['home'] = '/opt/openstack/mistral'

# Source build dependencies
default['openstack-mistral']['source']['dependencies'] = case node['platform_family']
when 'debian'
  %w(libssl-dev libyaml-dev libffi-dev libxml2-dev libxslt1-dev)
when 'fedora', 'rhel'
  %w(openssl-devel libyaml-devel libffi-devel libxml2-devel libxslt-devel)
end

# The actual home is set by the install recipe
default['openstack-mistral']['home'] = nil
default['openstack-mistral']['etc_dir'] = '/opt/openstack/etc'
default['openstack-mistral']['db_initialize']['enabled'] = false
default['openstack-mistral']['db_initialize']['superuser'] = 'root'
default['openstack-mistral']['db_initialize']['password'] = 'ilikerandompasswords'
default['openstack-mistral']['db_initialize']['allowed_hosts'] = 'localhost'

default['openstack-mistral']['templates']['logfile_source'] = 'logging.conf.erb'
default['openstack-mistral']['templates']['logfile_cookbook'] = 'openstack-mistral'
# default['openstack-mistral']['logfiles_mode']