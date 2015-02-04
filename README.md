# openstack-mistral-cookbook

Sets up and configures [**Mistral Workflow Service**](https://github.com/stackforge/mistral) on a chef node.

## Supported Platforms

There are no restrictions for platforms, it should support deb or rpm based systems. Tested to work on *ubuntu* and *centos*.

## Cookbook dependencies

Cookbook depends on other cookbooks: ***build-essential, python, git, runit***.

## Attributes

| Key | Type | Description | Default |
| --- | :---: | :--- | :---: |
| `['openstack-mistral']['install_method']` | String | Mistral installation method (by default installs from git). | `:source` |
| `[‘openstack-mistral’][‘source’][‘git_url’] ` | String | Git source url. (https://github.com/stackforge/mistral)  |
| `['openstack-mistral']['source']['git_revision']` | String | Git branch or revision. If none is given the latest is used. | `nil` |
| `['openstack-mistral']['source']['git_action']` | String | Action for git provider. If none is given the source will be checked out. | `nil` |
| `['openstack-mistral']['prefix_dir']` | String | Specifies the base directory under which mistral code is be checkout. If it's not given /opt/openstack is used. | `nil` |
| `['openstack-mistral']['etc_dir']` | String | Specifies the configuration directory where mistral service configrution files are places. If it's not given /opt/openstack/etc is used. | `nil` |
| `['openstack-mistral']['logfiles_mode']` | String | Sets log file permission when `touch_logfiles` resource attribute is used. | `'0644'` |

## Usage

Cookbook provides **mistral_service** resource provider which allows you to deploy mistral service, populate its configuration and start it up. Mistral python application is started via **runit** system service. Related services like: *RabbitMQ* or *MySQL* **are neither installed nor configured** by this cookbook.

### mistral_service attributes

 * **:bind_address** - Specifies address where mistral **api** server listens by default `0.0.0.0`.
 * **:port** - Specifies port of **api** server by default `8989`.
 * **:run_user** - Runs service as specified user. If it's different from default user should be created manually. *Default*: `mistral`.
 * **:run_group** - Same as the previous for setting the group. *Default*: `mistral`.
 * **:conf_source** - Mistral configuration file template name. *Default*: `mistral.conf.erb`. 
 * **:log_source** - Mistral log file template name. *Default*: `logging.conf.erb`.
 * **:conf_cookbook** and **:log_cookbook** - Set the previous template files cookbook locations.
 * **:options** - Use to specify options which are passed to the *mistral.conf*.
 * **:log_variables** - Use to specify template variables which are passed to the *logging.conf*.
 * **:touch_logfiles** - An array of log file paths which will be use should be passed here. This will create files and set privileges as the service might be run under normal system user.
 * **:starts** - Specify an array of (*:api, :engine, :executor*) to set servers which are started by mistral. If nothing is given mistral starts all three of them.

### Invocation example

```
mistral_service 'st2' do
  action [ :create, :start ]
  options({
    DEFAULT: {
      qpid_hostname=broker.example.net
    },
    api: {
      host=mistral-api.host
      port=8989
    }
  })
  touch_logfiles [
      '/var/log/mistral.log'
    ]
  starts [ :executor, :engine ]
end
```

The code above will create runit mistral service called **mistrall-st2** and prepare its log and service configuration.

Without providing valid configuration **mistral won't start**, i.e if you haven't setup mysql or rabbitmq. 
**bind_address** and **port** will be overwritten if you start an **api** instance (for example if you didn't explicitly set the **starts** attribute).

### openstack-mistral::default

Include `openstack-mistral` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[openstack-mistral::default]"
  ]
}
```

## License and Authors

License:: Apache 2.0 
Author:: StackStorm (<info@stackstorm.com>)
Author:: Denis Baryshev (<dennybaa@gmail.com>)
