#
# Cookbook Name:: openstack-mistral
# Recipe:: default
#
# Copyright (C) 2015 StackStorm (info@stackstorm.com)
#

include_recipe 'python::default'
include_recipe 'runit::default'

mistral_service 'st2' do
  action [ :create, :start ]
  touch_logfiles [
      '/var/log/mistral.log'
    ]
end
