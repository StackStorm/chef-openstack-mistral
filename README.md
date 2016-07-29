# OpenStack Mistral chef cookbook

[cookbook]: https://github.com/StackStorm/chef-openstack-mistral

Sets up and configures [**Mistral Workflow Service**](https://github.com/openstack/mistral) on a Chef node.

## Compatibility

Use version **<0.2.3** of this cookbook with chef **<12.4.0**.

As of version **0.3.0**, Mistral will be installed using Stackstorm's Packagecloud packages.

## Supported Platforms

There are no restrictions for platforms, cookbook should support major debian, fedora and rhel platforms. Tested to work on *ubuntu*, *debian* and *centos*.

## Cookbook dependencies

Cookbook depends on other cookbooks: ***apt, packagecloud, database, postgresql***.

## Attributes

| Key | Type | Description | Default |
| --- | :---: | :--- | :---: |
| `['openstack-mistral']['etc_dir']` | String | Specifies the configuration directory where mistral configuration files are placed. | `'/opt/openstack/etc'` |
| `['openstack-mistral']['db_initialize']['enabled']` | Boolean | If enabled, cookbook will try to create database for mistral. | `false` |
| `['openstack-mistral']['db_initialize']['upgrade]` | Boolean | If enabled, cookbook will try to upgrade database for mistral once. | `false` |
| `['openstack-mistral']['db_initialize']['populate]` | Boolean | If enabled, cookbook will try to populate database for mistral once. | `false` |
| `['openstack-mistral']['db_initialize']['db_name]` | String | Database name. | `'mistral` |
| `['openstack-mistral']['db_initialize']['db_username]` | String | Database user which own `db_name` database . | `'mistral` |
| `['openstack-mistral']['db_initialize']['db_superuser]` | String | User which create role and databases. | `'postgres` |
| `['postgres]['db_initialize']['db_superuser_password]` | String | Superuser password. | `'ilikerandompasswords'` |
| `['openstack-mistral']['db_initialize']['allowed_hosts']` | String | Hosts which will be allowed to access mistral database. | `'localhost'` |
| `['openstack-mistral']['config']` | Hash | Configurations to be overwritten in `mistral.conf`. | `{}` |

## Usage

Cookbook install `st2mistral` package, overwrite its configuration with `node['openstack-mistral']['config']` attributes and start it up. `st2mistral` package also install a default ***mistral*** user and setup logging. Related services like: *RabbitMQ* **are neither installed nor configured** by this cookbook.

Include this cookbook from other cookbooks or directly from runlist:

```ruby
include_recipe 'openstack-mistral::default'
```

In case `db_initialize.enabled` is provided, `_database.rb` recipe will try to install `postgresql`, create user `mistral` and create database **mistral**. Default this is set to `false`.

```ruby
include_recipe 'openstack-mistral::_database'
```

Initial schema upgrade and populate of database can also be done once if ***upgrade*** or ***populate** are set.

## Development

Setup development environment using [ChefDK](https://downloads.chef.io/chef-dk/). This is to ensure development and testing infrastructure (TravisCI) are using the same Ruby and libraries.

## License and Authors

License:: Apache 2.0 

- Author:: StackStorm (<info@stackstorm.com>)
- Author:: Denis Baryshev (<dennybaa@gmail.com>)

## Contributors

- Author:: Bao Nguyen (<ngqbao@gmail.com>)
