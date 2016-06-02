include_recipe 'apt'

type = 'deb'
case node['platform_family']
when 'fedora', 'rhel'
  type = 'rpm'
end

packagecloud_repo "StackStorm/stable" do
  type type
end

package 'st2mistral'
