include_recipe 'apt'

type = case node['platform_family']
       when 'fedora', 'rhel'
         'rpm'
       else
         'deb'
       end

packagecloud_repo 'StackStorm/stable' do
  type type
end

package 'st2mistral'

service 'mistral' do
  action :nothing
  supports status: true, start: true, stop: true, restart: true
end

service 'mistral-api' do
  action :nothing
  supports status: true, start: true, stop: true, restart: true
end

service 'mistral-server' do
  action :nothing
  supports status: true, start: true, stop: true, restart: true
end

# ensure directories are managed
[
  node['openstack-mistral']['etc_dir']
].each do |path|
  directory "creating mistral directory #{path}" do
    path path
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

template '/etc/mistral/mistral.conf' do
  source 'mistral.conf.erb'
  variables(
    options: node['openstack-mistral']['config']
  )
  mode '0644'
  action :create
  notifies :restart, 'service[mistral]', :delayed
  notifies :restart, 'service[mistral-api]', :delayed
  notifies :restart, 'service[mistral-server]', :delayed
end
