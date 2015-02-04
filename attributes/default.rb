default['openstack-mistral']['install_method'] = :source
default['openstack-mistral']['source']['git_url'] = 'https://github.com/stackforge/mistral'
default['openstack-mistral']['source']['git_revision'] = nil
default['openstack-mistral']['source']['git_action']   = nil
default['openstack-mistral']['source']['prefix_dir'] = '/opt/openstack'

# Specify the following attributes to set paths for the source method.
default['openstack-mistral']['prefix_dir'] = nil 
default['openstack-mistral']['etc_dir'] = nil
default['openstack-mistral']['logfiles_mode'] = '0644'
