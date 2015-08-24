require 'net/http'
require 'shellwords'

module MistralCookbook
  module Helpers
    include Chef::DSL::IncludeRecipe

    def start_services
      @start_services ||= Array(new_resource.starts).map {|s| s.to_s}
    end

    def config_options
      @config_options ||= begin
        if start_services.empty? || start_services.include?('api')
          # For mistral api service we use provided bind_address and port
          Mash.new(new_resource.options).merge({
            api: {
              host: new_resource.bind_address,
              port: new_resource.port
            }
          })
        else
          Mash.new(new_resource.options)
        end
      end
    end

    def create_logfile_destinations
      return if new_resource.run_user == 'root'

      new_resource.logfile_creates.each do |path|
        file_dir = ::File.dirname(path)

        directory "#{new_resource.name} log file directory: #{file_dir}" do
          path file_dir
          action :create
          # no managing of directory owner, group or mode
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

    def config_basename
      new_resource.service_name.to_s == 'default' ? 'mistral' :
        "mistral-#{new_resource.service_name}"
    end

    def config_file_base
      ::File.join(node['openstack-mistral']['etc_dir'], config_basename)
    end

    # Service provider mapping
    def service_provider
      @service_provider ||= begin
        cookbook_supports = [:upstart, :debian, :systemd, :redhat]
        platform_supports = Chef::Platform::ServiceHelpers.service_resource_providers
        avail = cookbook_supports.select { |sv| platform_supports.include? sv }

        if avail.empty?
            NotImplementedError.new("platform #{node[:platform]} " \
                                    "#{node[:platform_version]} not supported")
        end

        case node.platform_family
        when 'debian'
          avail.include?(:upstart) ? :upstart : :debian
        when 'rhel', 'fedora'
          avail.include?(:systemd) ? :systemd : :redhat
        else
          avail.first
        end
      end
    end

    def service_template(action, &block)
      path = case service_provider
        when :upstart
          "/etc/init/#{config_basename}.conf"
        when :redhat, :debian
          "/etc/init.d/#{config_basename}"
        when :systemd
          "/lib/systemd/system/#{config_basename}.service"
        end

      resource = template("#{new_resource.name} #{action} #{service_provider} init file", &block)
      resource.instance_eval do
        path(path)
        [:redhat, :debian].include?(service_provider) ? mode('0755') :
          mode('0644')
        action action
      end
      resource
    end

    def db_initialize
      db_drivers_install
      if !db_opts['enabled']
        return
      elsif !db_uri
        Chef::Log.error "Database option `database/connection' must be provided"
        raise ArgumentError.new
      elsif respond_to?(db_init_method)
        send(db_init_method)
      else
        Chef::Log.error "Database #{db_uri.scheme} doesn't support initialization!"
      end
    end

    def db_initialize_mysql
      if mysql_binary.empty?
        Chef::Log.error "Database can not be initialized, no mysql binary found"
        raise RuntimeError.new
      end

      nodb_cmd = mysql_cmdbase(db_uri.user, db_uri.password, db_uri.host)
      nodb_cmd << " #{db_name}" <<
        %q` -e 'exit' 2>&1 | grep -q 'Access denied for user\|Unknown database'`
      init_cmd = mysql_cmdbase(db_opts.superuser, db_opts.password, db_uri.host)
      init_cmd << %Q` -e "#{mysql_init_code}"`

      execute "#{new_resource.name} mysql initialize database #{db_name}" do
        command init_cmd
        only_if nodb_cmd
      end
    end

    def mysql_binary
      @mysql_binary ||= %x(which mysql 2>/dev/null).strip
    end

    def mysql_init_code
      identifed_by = "IDENTIFIED BY '#{db_uri.password}'" if !db_uri.password.to_s.empty?
      <<-EOP
        CREATE USER '#{db_uri.user}'@'#{db_opts.allowed_hosts}' #{identifed_by};
        CREATE DATABASE #{db_name};
        USE #{db_name}
        GRANT ALL ON #{db_name}.* TO '#{db_uri.user}'@'#{db_opts.allowed_hosts}';
      EOP
    end

    def mysql_cmdbase(user, password=nil, host=nil)
      list = [ user, password, host ]
      opts = [ '--protocol tcp' ]
      %w[-u -p -h].zip(list) do |k, v|
        w = v.to_s
        opts << "#{k}#{Shellwords.escape(w)}" if !w.empty?
      end
      "#{mysql_binary} #{opts.join(' ')}"
    end

    # db helpers
    def db_opts
      node['openstack-mistral']['db_initialize']
    end

    def db_uri
      @db_uri ||= URI(config_options['database']['connection']) rescue nil
    end

    def db_name
      @db_name ||= db_uri.path.gsub(/^\/+/, '')
    end

    def db_init_method
      :"db_initialize_#{db_uri.scheme}"
    end

    # Install python database drivers
    def db_drivers_install
      include_recipe('python::pip')
      case db_uri.scheme
      when 'mysql'
        python_pip "#{new_resource.name} :install mysql-python" do
          package_name 'mysql-python'
          virtualenv "#{home}/.venv"
          action :install
        end
      end
    end

    def home
      node['openstack-mistral']['home'] or
        raise ArgumentError, "['openstack-mistral']['home'] attribute is missing!"
    end

  end
end
