module MistralCookbook
  module Helpers
    include Chef::DSL::IncludeRecipe

    def prepare_packages
      chef_gem('hashie').run_action(:install)
      require 'hashie'

      load_install_helpers
      install_packages
    end

    def load_install_helpers
      method = node['openstack-mistral']['install_method'].to_s
      require_relative("#{method}_install")
      self.send :extend, MistralCookbook.const_get(method.capitalize + 'Install')

    rescue LoadErorr
      Chef::Log.error "Unsupported install_method: #{mistral.install_method}"
      raise
    end

    def service_name
      "mistral-#{new_resource.name}"
    end

    def prefix_dir
      type = node['openstack-mistral']['install_method']
      node['openstack-mistral'][:prefix_dir] || node['openstack-mistral'][type][:prefix_dir]
    end

    def mistral_home
      "#{prefix_dir}/mistral"
    end

    def etc_dir
      node['openstack-mistral'][:etc_dir] || "#{mistral_home}/etc"
    end

    def system_service_variables
      starts = Array(new_resource.starts).map {|s| s.to_s}.join(',')
      {
        service_name: service_name,
        cwd: mistral_home,
        run_user: new_resource.run_user,
        run_group: new_resource.run_group,
        config_file: "#{etc_dir}/#{new_resource.name}.conf",
        log_config: "#{etc_dir}/#{new_resource.name}_logging.conf",
        servers_option: (starts.empty? ? '' : "--server #{starts}")
      }
    end

  end
end
