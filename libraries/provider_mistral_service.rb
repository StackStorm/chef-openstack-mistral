require 'chef/provider/lwrp_base'
require_relative 'helpers'

class Chef
  class Provider
    class MistralService < Chef::Provider::LWRPBase
      include MistralCookbook::Helpers

      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      action :create do
        # Download and prepare packages
        prepare_packages

        directory "#{new_resource.name} :create #{etc_dir}" do
          path etc_dir
          mode '0755'
          recursive true
          action :create
        end

        options = ::Hashie::Mash.new(new_resource.options)
        starts = Array(new_resource.starts)

        # if we start an api node
        if starts.empty? || starts.any? { |i| "#{i}" == 'api' }       
          listen = ::Hashie::Mash.new({
            api: {
              host: new_resource.bind_address,
              port: new_resource.port
            }
          })
          options = options.deep_merge(listen)
        end

        template "#{new_resource.name} :create #{etc_dir}/#{new_resource.name}.conf" do
          path "#{etc_dir}/#{new_resource.name}.conf"
          source new_resource.conf_source
          cookbook new_resource.conf_cookbook
          variables(options: options)
          mode '0644'
          action :create
        end

        template "#{new_resource.name} :create #{etc_dir}/#{new_resource.name}_logging.conf" do
          path "#{etc_dir}/#{new_resource.name}_logging.conf"
          source new_resource.log_source
          cookbook new_resource.log_cookbook
          variables new_resource.log_variables
          action :create
        end

        # System users
        group "#{new_resource.name} :create mistral" do
          group_name 'mistral'
          action :create
        end

        user "#{new_resource.name} :create mistral" do
          username 'mistral'
          gid 'mistral'
          action :create
        end

        # runit service_name seems not working right..
        # create stopped service
        runit_service service_name do
          run_template_name 'mistral'
          options system_service_variables
          log false
          action :create
        end
      end

      action :delete do
        runit_service service_name do
          run_template_name 'mistral'
          options system_service_variables
          log false
          action [:stop, :disable]
        end
      end

      action :start do
        runit_service service_name do
          run_template_name 'mistral'
          options system_service_variables
          log false
          action [:enable, :start]
        end
      end

      action :stop do
        runit_service service_name do
          run_template_name 'mistral'
          options system_service_variables
          log false
          action :stop
        end
      end

      action :restart do
        runit_service service_name do
          run_template_name 'mistral'
          options system_service_variables
          log false
          action [:enable, :restart]
        end
      end

      def touch_logfiles
        return if new_resource.run_user == 'root'

        new_resource.touch_logfiles.each do |path|
          file_dir = ::File.dirname(path)

          directory "#{new_resource.name} log file directory: #{file_dir}" do
            path file_dir
            owner 'root'
            group 'root'
            mode '0755'
            action :create
          end

          file "#{new_resource.name} touch #{path}" do
            path path
            owner new_resource.run_user
            group new_resource.run_group
            mode node['openstack-mistral']['logfiles_mode']
            action :create_if_missing
          end
        end
      end

    end
  end
end
