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
