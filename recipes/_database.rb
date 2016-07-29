include_recipe 'openstack-mistral::default'

# unless node attribute is set, we going to skip all of below
return unless node['openstack-mistral']['db_initialize']['enabled']

node.override['postgresql']['password']['postgres'] = node['openstack-mistral']['db_initialize']['db_password']
include_recipe 'database::postgresql'
include_recipe 'postgresql::server'

postgresql_connection_info = {
  host: node['openstack-mistral']['db_initialize']['allowed_hosts'],
  port: node['openstack-mistral']['db_initialize']['port'],
  username: node['openstack-mistral']['db_initialize']['db_superuser'],
  password: node['openstack-mistral']['db_initialize']['db_superuser_password']
}

# Create a postgresql user but grant no privileges
postgresql_database_user node['openstack-mistral']['db_initialize']['db_username'] do
  connection postgresql_connection_info
  password node['openstack-mistral']['db_initialize']['db_password']
  action :create
end

# create a postgresql database with additional parameters
postgresql_database node['openstack-mistral']['db_initialize']['db_name'] do
  connection postgresql_connection_info
  template 'DEFAULT'
  encoding 'DEFAULT'
  tablespace 'DEFAULT'
  connection_limit '-1'
  owner node['openstack-mistral']['db_initialize']['db_username']
  action :create
end

# upgrade and populate database only once.
execute 'populate' do
  command '/opt/stackstorm/mistral/bin/mistral-db-manage --config-file /etc/mistral/mistral.conf upgrade head && touch /etc/mistral/upgraded'
  not_if { File.exist?('/etc/mistral/upgraded') }
  action :run
end
node.override['openstack-mistral']['db_initialize']['upgrade'] = false

execute 'populate' do
  command '/opt/stackstorm/mistral/bin/mistral-db-manage --config-file /etc/mistral/mistral.conf populate && touch /etc/mistral/populated'
  not_if { File.exist?('/etc/mistral/populated') }
  action :run
end
node.override['openstack-mistral']['db_initialize']['populate'] = false
