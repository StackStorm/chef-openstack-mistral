include_recipe 'apt'

type = 'deb'
case node['platform_family']
when 'fedora', 'rhel'
  type = 'rpm'
end

packagecloud_repo "StackStorm/stable" do
  type type
end

directory ":create #{node['openstack-mistral']['home']}" do
  path node['openstack-mistral']['home']
  mode '0755'
  recursive true
  action :create
end

package 'st2mistral'
