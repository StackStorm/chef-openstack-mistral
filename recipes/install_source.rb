#
# Cookbook Name:: openstack-mistral
# Recipe:: install_source
#
# Copyright (C) 2015 StackStorm (info@stackstorm.com)
#

# provide mistral home attribute
node.override['openstack-mistral']['home'] = node['openstack-mistral']['source']['home']
home = node['openstack-mistral']['home']
conf = node['openstack-mistral']['source']

include_recipe('build-essential::default')
include_recipe('git::default')
include_recipe('python::default')

dependencies = node['openstack-mistral']['source']['dependencies'] || []
dependencies.each {|dep| package dep}
if dependencies.empty?
  Chef::Log.error "#{new_resource} dependencies for #{node[:platform]} not found!"
end

directory ":create #{home}" do
  path home
  mode '0755'
  recursive true
  action :create
end

git "fetch #{conf.git_url}" do
  destination home
  repository conf.git_url
  revision conf.git_revision
  action(conf.git_action || :checkout)

  notifies :upgrade, "python_pip[:install #{home}/requirements.txt]"
end

python_virtualenv ":create #{home}/.venv" do
  path "#{home}/.venv"
  options '--no-site-packages'
  action :create
end

python_pip ":install #{home}/requirements.txt" do
  package_name "-r #{home}/requirements.txt"
  virtualenv "#{home}/.venv"
  action :install

  notifies :run, "execute[:run setup.py]"
end

execute ":run setup.py" do
  cwd home
  command "sh -c '. .venv/bin/activate; python setup.py develop'"
  action :nothing
end
