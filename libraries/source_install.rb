module MistralCookbook
  module SourceInstall

    def install_packages
      return
      install_dependencies
      fetch_packages
    end

    def fetch_packages
      # Include recipes needed for installation from source
      include_recipe('build-essential::default')
      include_recipe('git::default')

      gitconf = {
        url: node['openstack-mistral']['source'][:git_url],
        revision: node['openstack-mistral']['source'][:git_revision],
        action: node['openstack-mistral']['source'][:git_action] || :checkout
      }

      directory "#{new_resource.name} :create #{prefix_dir}" do
        path prefix_dir
        mode '0755'
        recursive true
        action(prefix_dir == '/' ? :nothing : :create)
      end

      git "#{new_resource.name} :#{git_action} #{gitconf[:url]}" do
        destination mistral_home
        repository gitconf[:url]
        revision gitconf[:revision]
        notifies :upgrade, "python_pip[#{new_resource.name} :install #{mistral_home}/requirements.txt]"
        notifies :run, "execute[#{new_resource.name} :run setup.py]"
        action gitconf[:action]
      end

      python_virtualenv "#{new_resource.name} :create #{mistral_home}/.venv" do
        path "#{mistral_home}/.venv"
        options '--no-site-packages'
        action :create
      end

      python_pip "#{new_resource.name} :install #{mistral_home}/requirements.txt" do
        package_name "#{mistral_home}/requirements.txt"
        options '-r'
        virtualenv "#{mistral_home}/.venv"
        action  :install
      end

      execute "#{new_resource.name} :run setup.py" do
        cwd mistral_home
        command "sh -c '. .venv/bin/activate; python setup.py develop'"
        action :nothing
      end
    end

    def install_dependencies
      dependencies = value_for_platform_family(
          'debian' => %w(libssl-dev libyaml-dev libffi-dev libxml2-dev libxslt1-dev python-dev libmysqlclient-dev),
          %w(rhel fedora) => %w(openssl-devel libyaml-devel libffi-devel libxml2-devel libxslt-devel python-devel mysql-devel),
          'default' => []
        )
      Chef::Log.error "#{new_resource} doesn't support platform #{node[:platform]}!" if dependencies.empty?
      dependencies.each {|dep| package dep}
    end

    def system_service_variables
      super.merge({
        launch_cmd: ". .venv/bin/activate; python ./mistral/cmd/launch.py"
        })
    end

  end
end
