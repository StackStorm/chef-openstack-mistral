node.override['postgresql']['pg_gem']['version'] = '0.21.0'
include_recipe 'postgresql::server'
include_recipe 'postgresql::ruby'

# point at localhost. hard code creds.
connection_info = {
  host: '127.0.0.1',
  port: '5432',
  username: 'postgres',
  password: node['postgresql']['password']['postgres']
}

## resources we're testing
postgresql_database 'dataflounder' do
  connection connection_info
  action :create
end

postgresql_database_user 'animal' do
  connection connection_info
  password 'raaaaaaaaaaaaaaaaaaaaaaaaaaaaah'
  superuser true
  login true
  action :create
end
