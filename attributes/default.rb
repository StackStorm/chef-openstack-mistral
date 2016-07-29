# The home is set to null by package
default['openstack-mistral']['home'] = nil
default['openstack-mistral']['etc_dir'] = '/etc/mistral'

default['openstack-mistral']['db_initialize']['enabled'] = false

# NOTE: additionally gated by `/etc/mistral/upgraded` upon successful upgrade
default['openstack-mistral']['db_initialize']['upgrade'] = false
# NOTE: additionally gated by `/etc/mistral/populated` upon successful upgrade
default['openstack-mistral']['db_initialize']['populate'] = false

default['openstack-mistral']['db_initialize']['db_name'] = 'mistral'
default['openstack-mistral']['db_initialize']['db_username'] = 'mistral'
default['openstack-mistral']['db_initialize']['db_password'] = 'ilikerandompasswords'
default['openstack-mistral']['db_initialize']['superuser'] = 'postgres'
default['openstack-mistral']['db_initialize']['allowed_hosts'] = 'localhost'
default['openstack-mistral']['db_initialize']['port'] = 5432
# Per postgresql [cookbook](https://github.com/hw-cookbooks/postgresql),
# if this is not set, random password (using openssl) is setup
default['postgresql']['password']['postgres'] = 'ilikerandompasswords'

default['openstack-mistral']['config'] = {
  default: {
    transport_url: 'rabbit://guest:guest@127.0.0.1:5672'
  },
  api: {
    host: '0.0.0.0',
    port: 8989
  },
  coordination: {
  },
  database: {
    connection: "postgresql://#{node['openstack-mistral']['db_initialize']['db_username']}:#{node['openstack-mistral']['db_initialize']['db_password']}@#{node['openstack-mistral']['db_initialize']['allowed_hosts']}/#{node['openstack-mistral']['db_initialize']['db_name']}",
    max_pool_size: 50
  },
  engine: {
  },
  execution_expiration_policy: {
  },
  keystone_authtoken: {
  },
  matchmaker_redis: {
  },
  executor: {
  },
  matchmaker_ring: {
  },
  oslo_messaging_amqp: {
  },
  oslo_messaging_qpid: {
  },
  oslo_messaging_rabbit: {
  },
  pecan: {
    auth_enable: false
  }
}
