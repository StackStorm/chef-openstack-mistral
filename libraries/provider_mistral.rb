require 'shellwords'
require 'chef/provider/lwrp_base'
require_relative 'helpers'

class Chef
  class Provider
    class Mistral < Chef::Provider::LWRPBase

      include MistralCookbook::Helpers

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        conf = node['openstack-mistral']

        # Install mistral if recipe is given
        if node['openstack-mistral']['install_recipe']
          include_recipe(node['openstack-mistral']['install_recipe'])
        end

        # System default user and group
        group "#{new_resource.name} :create mistral" do
          group_name 'mistral'
          action :create
        end

        user "#{new_resource.name} :create mistral" do
          username 'mistral'
          gid 'mistral'
          action :create
        end

        directory "#{new_resource.name} :create #{conf.etc_dir}" do
          path conf.etc_dir
          mode '0755'
          recursive true
          action :create
        end

        templates = node['openstack-mistral']['templates']

        template "#{new_resource.name} :create #{config_file_base}.conf" do
          path "#{config_file_base}.conf"
          source 'mistral.conf.erb'
          cookbook 'openstack-mistral'
          variables(options: config_options)
          mode '0644'
          action :create
        end

        template "#{new_resource.name} :create #{config_file_base}_logging.conf" do
          path "#{config_file_base}_logging.conf"
          source templates.logfile_source
          cookbook templates.logfile_cookbook
          variables new_resource.logfile_options
          action :create
        end

        starts_opt = start_services.join(',')
        starts_opt = "--server #{starts_opt}" if !starts_opt.empty?

        service_template(:create) do
          source "#{service_provider}-init.erb"
          cookbook 'openstack-mistral'

          variables({
            service_name: config_basename,
            run_user: new_resource.run_user,
            run_group: new_resource.run_group,
            config_file: "#{config_file_base}.conf",
            log_config: "#{config_file_base}_logging.conf",
            home: Shellwords.escape(home),
            service_bin: "./mistral/cmd/launch.py",
            start_services: starts_opt
          })
        end

        db_initialize

        service_provider_klasss = Chef::Provider::Service.const_get(
                                    service_provider.to_s.capitalize)
        service "enable service #{config_basename}" do
          service_name config_basename
          action :enable
          provider service_provider_klasss
        end
      end

      action :delete do
        service_provider_klasss = Chef::Provider::Service.const_get(
                                    service_provider.to_s.capitalize)
        service "stop and disable service #{config_basename}" do
          service_name config_basename
          action [:stop, :disable]
          provider service_provider_klasss
        end
      end

      action :start do
        create_logfile_destinations
        service_provider_klasss = Chef::Provider::Service.const_get(
                                    service_provider.to_s.capitalize)
        service "start service #{config_basename}" do
          service_name config_basename
          action :start
          provider service_provider_klasss
        end
      end

      action :stop do
        service_provider_klasss = Chef::Provider::Service.const_get(
                                    service_provider.to_s.capitalize)
        service "stop service #{config_basename}" do
          service_name config_basename
          action :stop
          provider service_provider_klasss
        end
      end

      action :restart do
        service_provider_klasss = Chef::Provider::Service.const_get(
                                    service_provider.to_s.capitalize)
        service "restart service #{config_basename}" do
          service_name config_basename
          action :restart
          provider service_provider_klasss
        end
      end

    end
  end
end
