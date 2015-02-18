# OpenStack Mistral chef cookbook
Sets up and configures [**Mistral Workflow Service**](https://github.com/stackforge/mistral) on a chef node.

## Supported Platforms

There are no restrictions for platforms, cookbook should support major debian, fedora and rhel platforms. Tested to work on *ubuntu*, *debian* and *centos*.

## Cookbook dependencies

Cookbook depends on other cookbooks: ***build-essential, python, git, mysql***.

## Attributes

| Key | Type | Description | Default |
| --- | :---: | :--- | :---: |
| `['openstack-mistral']['install_recipe']` | String | Mistral recipe used to fetch mistral. Default option will fetch mistral from git repository. | `'openstack-mistral::install_source'` |
| `[‘openstack-mistral’][‘source’][‘git_url’] ` | String | Git source url. (https://github.com/stackforge/mistral)  |
| `['openstack-mistral']['source']['git_revision']` | String | Git branch or revision. If none is given the latest is used. | `nil` |
| `['openstack-mistral']['source']['git_action']` | String | Action for git provider. If none is given the source will be checked out. | `nil` |
| `['openstack-mistral']['source']['home']` | String | Specifies directory where source installation method will place mistral. | `'/opt/openstack/mistral'` |
| `['openstack-mistral']['etc_dir']` | String | Specifies the configuration directory where mistral configrution files are placed. | `'/opt/openstack/etc'` |
| `['openstack-mistral']['logfiles_mode']` | String | Sets log file permission for resource `logfile_creates` option. | `'0644'` |
| `['openstack-mistral']['db_initialize']['enabled']` | Boolean | If enabled, cookbook will try to create database for mistral. | `false` |
| `['openstack-mistral']['db_initialize']['superuser']` | String | Database user which can create databases and setup permissions. | `'root'` |
| `['openstack-mistral']['db_initialize']['password']` | String | Password of superuser. | `'ilikerandompasswords'` |
| `['openstack-mistral']['db_initialize']['allowed_hosts']` | String | Hosts which will be allowed to access mistral database. | `'localhost'` |


## Usage

Cookbook provides **mistral** resource provider which allows you to deploy mistral service, populate its configuration and start it up. Related services like: *RabbitMQ* or *MySQL* **are neither installed nor configured** by this cookbook.

Typical resource invocation may look like this:

```ruby
mistral 'default' do
  action [ :create, :start ]
  options({
    database: {
      connection: 'mysql://mistral:changeme@127.0.0.1:3306/mistral'
    }
  })
  starts [:api, :executor, :engine]
end
```

In case `db_initialize.enabled` is provided, cookbook will try to create database **mistral** as well as the **mistrall** user identified by password *changeme*. However a running instance of mysql should be already in its place prior to the resource invocation. 

The resource code above will bring up system service **mistral**. You can bring up several services by defining the resource multiple times. For names other than *default* the system service will be named as **mistral-myname**.

## Mistral LWRP (mistral)

Cookbook comes with *mistral* resource provider which brings up mistral service or multiple mistral services. Provider uses specified `install_recipe` attribute if it's given to fetch mistral.

After mistral is fetched provider initializes database, creates configuration and service files and as the last step it brings up services.

### mistral resource attributes

 * **:bind_address** - Specifies address where mistral **api** server listens by default `0.0.0.0`.
 * **:port** - Specifies port of **api** server by default `8989`.
 * **:run_user** - Runs service as specified user. If it's different from default user should be created manually. *Default*: `mistral`.
 * **:run_group** - Same as the previous for setting the group. *Default*: `mistral`.
 * **:options** - Use to specify options which are passed for the *mistral.conf* generation from the template.
 * **:logfile_source** - Mistral log file template cookbook path. *Default*: `logging.conf.erb`.
 * **:logfile_cookbook** - Cookbook of logfile template. If not given the one from this cookbook is used.
 * **:logfile_options** - Use to specify options to be passed for log configuration file template.
 * **:logfile_creates** - An array of log file paths which will pre-created by cookbook. Can be used when services are run with dropped privileges and don't have access to log directories such as */var/log*.
 * **:starts** - Specifies an array of [*:api, :engine, :executor*] components to start up by mistral.


## License and Authors

License:: Apache 2.0 

- Author:: StackStorm (<info@stackstorm.com>)
- Author:: Denis Baryshev (<dennybaa@gmail.com>)
